//
//  VIdeoListScreen.swift
//  SimpleVideoCam
//
//  Created by 夏英浩 on 3/25/21.
//  Copyright © 2021 AppCoda. All rights reserved.
//

import UIKit

class VIdeoListScreen: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var videos: [Video] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        videos = createArray()
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
}

extension VIdeoListScreen: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let video = videos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
        cell.setVideo(video: video)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("video: ",indexPath.row+1, "is selected")
    }
}
