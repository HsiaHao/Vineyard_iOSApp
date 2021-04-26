//
//  PhotoViewController.swift
//  SimpleVideoCam
//
//  Created by 夏英浩 on 3/30/21.
//  Copyright © 2021 AppCoda. All rights reserved.
//

import UIKit
import Photos
import AVKit
class PhotoViewController: UIViewController {
    
    private var videosResult = PHFetchResult<PHAsset>()
    @IBOutlet weak var imageView: UIImageView!
    var player : AVPlayerItem?
    var video_url : URL?
    var video_asset: AVAsset?
    var x = 3
    var userCollections: PHFetchResult<PHCollection>?
    @IBAction func testButton(_ sender: UIButton) {
        print("video_asset: ", video_asset)
        let avPlayerItem = AVPlayerItem(asset: video_asset!)
        print("item: ", avPlayerItem)
        performSegue(withIdentifier: "play", sender: avPlayerItem)
        
    }
    @IBAction func saveVideo(_ sender: UIButton) {
        print("save video to test album...")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createPhotoLibraryAlbum(name: "TestAlbum")
        
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        // fetch all video objects
        videosResult = PHAsset.fetchAssets(with: .video, options: options)
        print("result: ", videosResult.count)
        
        //load first video asset
        loadVideoAsset(assetCompletionHandler: { asset, errot in
            self.video_asset = asset
            //self.player = AVPlayerItem(asset: self.video_asset!)
            print("sucess get asset..")
            print(asset)
        })
        photoAuthorization()
        
        // fetch albums
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        print("number of albums: ", userCollections?.object(at: 0).localizedTitle=="食")
    }
    
    private func loadImage() -> UIImage? {
            let manager = PHImageManager.default()
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions())

            // 1
            var image: UIImage? = nil
            // 2
            manager.requestImage(for: fetchResult.object(at: 0), targetSize: CGSize(width: 647, height: 375), contentMode: .aspectFill, options: requestOptions()) { img, err  in
                // 3
                guard let img = img else { return }
                    image = img
                print("image handler")
            }
            return image
    }
    private func loadVideoAsset(assetCompletionHandler: @escaping (AVAsset?, Error?)-> Void){
        let manager = PHImageManager.default()
        let options_video: PHVideoRequestOptions = PHVideoRequestOptions()
        options_video.version = .original
        var video_asset: AVAsset?=nil
        manager.requestAVAsset(forVideo: videosResult.firstObject!, options: options_video) { asset, mix, info in
            self.x = 5
            //self.player = AVPlayerItem(asset: asset!)
            guard let asset = asset else{return }
            video_asset = asset
            assetCompletionHandler(video_asset, nil)
        }
        
    }
    
    private func fetchOptions() -> PHFetchOptions {
        // 1
        let fetchOptions = PHFetchOptions()
        // 2
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    private func requestOptions() -> PHImageRequestOptions {
        let requestOptions = PHImageRequestOptions()
        // 2
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }
    
    private func photoAuthorization() {
        // 1
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            // 2
            imageView.image = loadImage()
            print("segue to play...")
            //performSegue(withIdentifier: "play", sender: player)
        case .restricted, .denied:
            print("Photo Auth restricted or denied")
        case .notDetermined:
            // 3
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    // 4
                    DispatchQueue.main.async {
                        self.imageView.image = self.loadImage()
                    }
                case .restricted, .denied:
                    print("Photo Auth restricted or denied")
                case .notDetermined: break
                default: break
               }
            }
        default: break
        }
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
    // add photo to an album
    func createPhotoOnAlbum(photo: UIImage, album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: photo)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                // Album change request has failed
                return
            }
            // Get a placeholder for the new asset and add it to the album editing request
            guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                // Photo Placeholder is nil
                return
            }
            albumChangeRequest.addAssets([photoPlaceholder] as NSArray)
        }, completionHandler: { success, error in
            if success {
                // Saved successfully!
            }
            else if let e = error {
                print(e)
                // Save photo failed with error
            }
            else {
                print("succed save...")
                // Save photo failed with no error
            }
        })
    }
    
    // Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare...")
        if segue.identifier == "play" {
            print("to play...")
            let videoPlayerViewController = segue.destination as! AVPlayerViewController
            let playItem = sender as! AVPlayerItem
            videoPlayerViewController.player = AVPlayer(playerItem: playItem)
        }
    }

}
