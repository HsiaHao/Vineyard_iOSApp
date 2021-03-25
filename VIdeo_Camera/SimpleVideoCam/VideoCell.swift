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
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    func setVideo(video: Video){
        videoImageView.image = video.image
        videoTitleLabel.text = video.title
    }
    
}
