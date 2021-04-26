//
//  SimpleVideoCamController.swift
//  SimpleVideoCam
//
//  Created by Simon Ng on 17/10/2020.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import CoreLocation
import MapKit


class SimpleVideoCamController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet var cameraButton:UIButton!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    //timer
    var timer = Timer()
    
    let albumName = "Vineyard"
    let captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice!
    var videoFileOutput: AVCaptureMovieFileOutput!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var userCollections: PHFetchResult<PHCollection>?
    
    let screenWidth = UIScreen.main.bounds.width-10
    let screenHeight = UIScreen.main.bounds.height/2
    var selectedRow = 0
    var zone = 0
    var row = 0
    
    var fileURL: URL?
    var filename = "location.txt"
    var writeString = ""
    
    var pickerData:[[String]] = [["ZONE"],["1","2","3","4","5","6","7","8"],["ROW"],["1","2","3","4","5","6","7","8"]]
    @IBOutlet weak var videoListButton: UIButton!
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        scheduledTimerWithTimeInterval()
        checkLocationServices()
        configure()
    }
    
    // MARK: - Update GPS Data with timer
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateGPS), userInfo: nil, repeats: true)
    }
    @objc func updateGPS(){
        NSLog("counting..")
        let currentlocation = locationManager.location
        let locationTxt = String(currentlocation!.coordinate.longitude) + " " + String(currentlocation!.coordinate.latitude)+";"
        print(locationTxt)
        if isRecording{
            writeString += locationTxt
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            print("location error:")
        }
    }
    func checkLocationAuthorization() {
        print("check location auth")
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }

    // MARK: - Camera functions
    private func configure() {
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        // Get the back-facing camera for capturing videos
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        currentDevice = device
        print("format: ",currentDevice.formats)
        
        // Get the input data source
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            return
        }
        
        // Configure the session with the output for capturing video
        videoFileOutput = AVCaptureMovieFileOutput()
        
        // Configure the session with the input and the output devices
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(videoFileOutput)
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame

        // Bring the camera button and list button to front
        view.bringSubviewToFront(cameraButton)
        view.bringSubviewToFront(videoListButton)
        
        if let device = currentDevice {
                // 1
//            print("1")
                for vFormat in currentDevice!.formats {
                    // 2
//                    print("2")
                    let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
                    let frameRates = ranges[0]
//                    print("rate: ", frameRates)
                    // 3
                    if frameRates.maxFrameRate == 240 {
//                        print("3")
                        // 4
                        do{
//                            print("rate: ",frameRates.maxFrameDuration)
                            try device.lockForConfiguration()
                            device.activeFormat = vFormat as AVCaptureDevice.Format
                            device.activeVideoMinFrameDuration = frameRates.minFrameDuration
                            device.activeVideoMaxFrameDuration = frameRates.minFrameDuration
                            device.unlockForConfiguration()
                        }catch{
                            NSLog("An Error occurred: \(error.localizedDescription))")
                        }
                            
                    }
                }
            }
        print("framerate: ", device.activeFormat)
        captureSession.startRunning()
    }
    // Create Album
    func createPhotoLibraryAlbum(name: String) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an album with parameter name
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            // Get a placeholder for the new album
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    fatalError("Album placeholder is nil")
                }

                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album: PHAssetCollection = fetchResult.firstObject else {
                    // FetchResult has no PHAssetCollection
                    return
                }

                // Saved successfully!
                print(album.assetCollectionType)
            }
            else if let e = error {
                print(e)
                // Save album failed with error
            }
            else {
                print("saved sucessed...")
                // Save album failed with no error
            }
        })
    }
    
    // MARK: -  Camera Action methods
    @IBAction func toList(_ sender: UIButton) {
        performSegue(withIdentifier: "videoList", sender: nil)
    }
    
    @IBAction func capture(sender: AnyObject) {
        if !isRecording {
            isRecording = true
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: nil)
            
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecording(to: outputFileURL, recordingDelegate: self)
        } else {
            isRecording = false
            
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            cameraButton.layer.removeAllAnimations()
            let titleItem =  AVMutableMetadataItem()
            titleItem.identifier = AVMetadataIdentifier.commonIdentifierTitle
            videoFileOutput?.stopRecording()
            //print("outputdata: ", videoFileOutput.availableVideoCodecTypes)
            
            // finish recording and write gps data to txt file
            do {
                try writeString.write(to: fileURL!, atomically: true, encoding: .utf8)
            } catch {
                print(error.localizedDescription)
            }
            writeString = ""
            //read string
            print("Finish Recording and Location data:")
            var readString = ""
            do{
                readString = try String(contentsOf: fileURL!)
                for s in readString.split(separator: ";"){
                    print("Coordinate: ", s)
                }
                print("")
                
            }catch let error as NSError{
                print(error)
            }
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVideo" {
            let videoPlayerViewController = segue.destination as! AVPlayerViewController
            let videoFileURL = sender as! URL
            videoPlayerViewController.player = AVPlayer(url: videoFileURL)
        }
        if segue.identifier == "videoList" {
            print("go to list...")
        }
    }

}
// MARK: - AVCapture Delegate
extension SimpleVideoCamController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print(error ?? "")
            return
        }
        //Save to album
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        // check if an album exist. If not create one
        var exist_album = false
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        let number_of_album = userCollections?.count
        for i in 0...number_of_album!-1{
            if userCollections?.object(at: i).localizedTitle==albumName{
                exist_album = true
            }
//            print(userCollections?.object(at: i).localizedTitle)
        }
        if exist_album==false{
            createPhotoLibraryAlbum(name: albumName)
            print("create new test album...")
        }else{
            print("the album exists...")
        }
        
        //save the video to the vineyard album
        var assetAlbum: PHAssetCollection?
        
        //find the vineyard album
        let list = PHAssetCollection
            .fetchAssetCollections(with: .album, subtype: .any, options: nil)
        list.enumerateObjects({ (album, index, stop) in
            let assetCollection = album
            if self.albumName == assetCollection.localizedTitle {
                assetAlbum = assetCollection
                stop.initialize(to: true)
            }
        })
        // assetalbum -> vinyard album
        // save the video to vineyard album
        PHPhotoLibrary.shared().performChanges({
            //添加的相机胶卷
            let result = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            //是否要添加到相簿
            if !self.albumName.isEmpty {
                let assetPlaceholder = result?.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest(for:assetAlbum!)
                albumChangeRequset!.addAssets([assetPlaceholder!]  as NSArray)
            }
        })
        popUpPicker()
    }
    
    //Mark: - UIPickerView
    func popUpPicker(){
        let vc = UIViewController()
        vc.preferredContentSize=CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.delegate = self
        pickerView.dataSource=self
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select Zone and Row", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        alert.setValue(vc, forKey: "contentViewController")
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
                }))
                
                alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
                    self.selectedRow = pickerView.selectedRow(inComponent: 0)
                    //self.selectedRowTextColor = pickerView.selectedRow(inComponent: 1)
                    //let selected = Array(self.backGroundColours)[self.selectedRow]
                    //let selectedTextColor = Array(self.backGroundColours)[self.selectedRowTextColor]
                    //let colour = selected.value
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "ZONE:" //header
        } else if component == 1 {
            return "\(row + 1)" //value
        } else if component == 2 {
            return "ROW:" //header
        } else if component == 3 {
            return "\(row+1)" //value
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row, component)
        if component==1{
            self.zone = row+1
        }
        if component==3{
            self.row = row+1
        }
        print("Selected Zone: ",zone," Row: ",self.row)
    }
}

// MARK: - GPS CLLOcation Delegate
extension SimpleVideoCamController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let loc = "Location Update: " + String(location.coordinate.latitude) + " " + String(location.coordinate.longitude)

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
