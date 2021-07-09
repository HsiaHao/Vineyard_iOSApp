//
//  VideoCell.swift
//  SimpleVideoCam
//
//  Created by 夏英浩 on 3/25/21.
//  Copyright © 2021 AppCoda. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var rowLabel: UILabel!
    
    func setVideo(video: Video){
        videoImageView.image = video.image
    }
    func setVideoTest(variety: String, plot: String, row: String){
        varietyLabel.text = variety
        plotLabel.text = "plot: "+plot
        rowLabel.text = "row: "+row
    }
    func setImg(img: UIImage){
        videoImageView.image = img
    }
    
    
}
