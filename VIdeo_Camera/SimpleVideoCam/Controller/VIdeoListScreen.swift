//
//  VIdeoListScreen.swift
//  SimpleVideoCam
//
//  Created by 夏英浩 on 3/25/21.
//  Copyright © 2021 AppCoda. All rights reserved.
//

import UIKit
import AVKit
import Photos

class VIdeoListScreen: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var videos: [Video] = []
    var videoAssets: [VideoAsset] = []
    let staticVar = Variable()
    var assetsFetchResults:PHFetchResult<PHAsset>!
    var imageManager:PHCachingImageManager!
    var numberOfVideos = 0
    var video_asset: [AVAsset] = []
    var defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        videos = createArray()
        videoAssets = fetchVideoInAlbum()
        numberOfVideos = assetsFetchResults.count
        fetchVideoAsset()
    }
    
    func createArray() ->[Video]{
        
        var tempVideos: [Video] = []
        
        let video1 = Video(image: UIImage(named: "video1")!, title: "Video_1")
        let video2 = Video(image: UIImage(named: "video1")!, title: "Video_2")
        let video3 = Video(image: UIImage(named: "video2")!, title: "Video_3")
        let video4 = Video(image: UIImage(named: "video2")!, title: "Video_4")
        let video5 = Video(image: UIImage(named: "video3")!, title: "Video_5")
        let video6 = Video(image: UIImage(named: "video3")!, title: "Video_6")
        let video7 = Video(image: UIImage(named: "video4")!, title: "Video_7")
        let video8 = Video(image: UIImage(named: "video4")!, title: "Video_8")
        
        tempVideos.append(video1)
        tempVideos.append(video2)
        tempVideos.append(video3)
        tempVideos.append(video4)
        tempVideos.append(video5)
        tempVideos.append(video6)
        tempVideos.append(video7)
        tempVideos.append(video8)
        
        
        
        return tempVideos
        
    }
    
    //fetch photos
    func fetchVideoInAlbum()->[VideoAsset]{
        var assetAlbum: PHAssetCollection?
        // store the Request result
       
        
        //find the vineyard album
        let list = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        list.enumerateObjects({ (album, index, stop) in
            let assetCollection = album
            if "Vineyard" == assetCollection.localizedTitle {
                assetAlbum = assetCollection
                stop.initialize(to: true)
            }
        })
        //print("asset album: ", assetAlbum)
        // get vineyard album in assetAlbun
        
        let resultsOptions = PHFetchOptions()
        resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        resultsOptions.predicate = NSPredicate(format: "mediaType = %d",PHAssetMediaType.video.rawValue)
        assetsFetchResults = PHAsset.fetchAssets(in: assetAlbum! , options: resultsOptions)
        print("test.......: #number of Videos ",assetsFetchResults.count)
        
//        let allVideosOptions = PHFetchOptions()
//        allVideosOptions.predicate = NSPredicate(format: "mediaType = %d",PHAssetMediaType.video.rawValue)
//        assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: allVideosOptions)
//        print("asset: ",assetsFetchResults[0])
        
        return []
    }
    
    func fetchVideoAsset(){
        let manager = PHImageManager.default()
        let options_video: PHVideoRequestOptions = PHVideoRequestOptions()
        options_video.version = .original
        for i in 0...numberOfVideos-1{
            manager.requestAVAsset(forVideo: assetsFetchResults[i], options: options_video) { asset, mix, info in
                guard let asset = asset else{return }
                self.video_asset.append(asset)
                
            }
        }

    }
    
    // Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare...")
        if segue.identifier == "playVideo" {
            print("to play...")
            let videoPlayerViewController = segue.destination as! AVPlayerViewController
            let playItem = sender as! AVPlayerItem
            videoPlayerViewController.player = AVPlayer(playerItem: playItem)
        }
    }
}

extension VIdeoListScreen: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return videos.count
        return assetsFetchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let video = videos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
//       let size = CGSize(width: 30, height: 20)
//       cell.setVideo(video: video)
        let videoAsset = assetsFetchResults[indexPath.row]
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let dateKey = formatter.string(from: videoAsset.creationDate!)
        // infos : variety. plot, row
        var infos = [String]()
        print("datekey:",dateKey)
        if defaults.object(forKey: dateKey) != nil{
            //print("find date video:", defaults.object(forKey: dateKey))
            let array = defaults.object(forKey: dateKey)! as? [String] ?? [String]()
            infos.append(array[0])
            infos.append(array[1])
            infos.append(array[2])
        }
        //print("date from list :",videoAsset.creationDate)
        print("infos", infos)
        let format1 = DateFormatter()
        format1.dateStyle = .short
        cell.setVideoTest(variety: infos[0], plot: infos[1], row: infos[2])
        cell.setImg(img: UIImage(named: "video2")!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("video: ",indexPath.row+1, "is selected")
        let avPlayerItem = AVPlayerItem(asset: video_asset[indexPath.row])
        print("KEY")
        print(video_asset[indexPath.row].availableMetadataFormats)
        performSegue(withIdentifier: "playVideo", sender: avPlayerItem)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
}

