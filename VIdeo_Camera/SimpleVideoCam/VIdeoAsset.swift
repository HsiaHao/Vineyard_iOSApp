//
//  VIdeoAsset.swift
//  SimpleVideoCam
//
//  Created by 夏英浩 on 4/7/21.
//  Copyright © 2021 AppCoda. All rights reserved.
//

import Foundation
import Photos


class VideoAsset {
    //相簿名称
    var title:String?
    //相簿内的资源
    var fetchResult:PHFetchResult<PHAsset>
     
    init(title:String?,fetchResult:PHFetchResult<PHAsset>){
        self.title = title
        self.fetchResult = fetchResult
    }
}
