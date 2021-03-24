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


class SimpleVideoCamController: UIViewController {

    @IBOutlet var cameraButton:UIButton!
    
    let captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice!
    var videoFileOutput: AVCaptureMovieFileOutput!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load...")
        configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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

        // Bring the camera button to front
        view.bringSubviewToFront(cameraButton)
        
        
        if let device = currentDevice {
                // 1
            print("1")
                for vFormat in currentDevice!.formats {
                    // 2
                    print("2")
                    let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
                    let frameRates = ranges[0]
                    print("rate: ", frameRates)
                    // 3
                    if frameRates.maxFrameRate == 240 {
                        print("3")
                        // 4
                        do{
                            print("rate: ",frameRates.maxFrameDuration)
                            print("set rate to 240 fps")
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
    
    // MARK: - Action methods
    
    @IBAction func unwindToCamera(segue:UIStoryboardSegue) {
        
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
            videoFileOutput?.stopRecording()
            print("outputdata: ", videoFileOutput.availableVideoCodecTypes)
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVideo" {
            let videoPlayerViewController = segue.destination as! AVPlayerViewController
            let videoFileURL = sender as! URL
            videoPlayerViewController.player = AVPlayer(url: videoFileURL)
        }
    }

}

extension SimpleVideoCamController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print(error ?? "")
            return
        }
        //Save to album
        let asset = AVAsset(url: outputFileURL)
        let formatsKey = "availableMetadataFormats"

        asset.loadValuesAsynchronously(forKeys: [formatsKey]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: formatsKey, error: &error)
            if status == .loaded {
                for format in asset.availableMetadataFormats {
                    let metadata = asset.metadata(forFormat: format)
                    print(metadata)
                    // process format-specific metadata collection
                }
            }
        }
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        //print(AVAssetExportSession.exportPresets(compatibleWith: asset) )
//        PHPhotoLibrary.requestAuthorization { status in
//            if status == .authorized {
//                // Save the movie file to the photo library and cleanup.
//                PHPhotoLibrary.shared().performChanges({
//                    let options = PHAssetResourceCreationOptions()
//                    options.shouldMoveFile = true
//                    let creationRequest = PHAssetCreationRequest.forAsset()
//                    creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
//                }, completionHandler: { success, error in
//                    if !success {
//                        print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
//                    }
//                    //cleanup()
//                }
//                )
//            }}
        //PHAsset
        let avAsset = AVAsset(url: outputFileURL)
        let player = AVPlayer(url: outputFileURL)
        for track in player.currentItem!.tracks{
            print("current framerate: ", track.currentVideoFrameRate)
        }
        //let imageManager = PHCachingImageManager()
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = .current
//        let comp = AVComposition(url: outputFileURL)
//        let avAsset = AVAsset(url: outputFileURL)
//        for track in av.tracks(withMediaType: AVMediaType.video) {
//            for segment in track.segments {
//              print("track:")
//              dump(segment)
//            }
//          }
        // Chech meta data
        //let asset = AVAsset(url: outputFileURL)
        //let formatsKey = "availableMetadataFormats"
        
        // build a mutable video object
        let fullRange = CMTimeRange(start: CMTime.zero, duration: CMTime(value: 30, timescale: 1))
        let emptyComposition = AVMutableComposition()
        let track = emptyComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: 1)
        let initialSegment = AVCompositionTrackSegment(url: outputFileURL, trackID: 1, sourceTimeRange: fullRange, targetTimeRange: fullRange)

        track!.segments = [initialSegment]
        
        let firstHalf = CMTimeRange(start: CMTime.zero, duration: CMTime(value: 15, timescale: 1))

        track!.scaleTimeRange(firstHalf, toDuration: fullRange.duration)
        //
//        asset.loadValuesAsynchronously(forKeys: [formatsKey]) {
//            var error: NSError? = nil
//            let status = asset.statusOfValue(forKey: formatsKey, error: &error)
//            if status == .loaded {
//                for format in asset.availableMetadataFormats {
//                    let metadata = asset.metadata(forFormat: format)
//                    print("data:")
//                    print(metadata)
//                }
//            }
//        }
        
        performSegue(withIdentifier: "playVideo", sender: outputFileURL)
    }
}
