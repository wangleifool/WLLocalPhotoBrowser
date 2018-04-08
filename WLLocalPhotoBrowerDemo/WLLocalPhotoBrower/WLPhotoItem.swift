//
//  WLPhotoItem.swift
//  LikeUber
//
//  Created by lei wang on 2018/3/29.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import Foundation
import Photos

class WLPhotoItem {
    var thumbImage: UIImage?
    var sourceView: UIView? //图片在上一层VC所在的视图
    var image: UIImage?
    var imageUrl: NSURL?
    var imageAsset: PHAsset? //Photos框架的照片资源对象
    
    // 提供image url初始化
    init(sourceView: UIView?,thumbImage: UIImage,imageUrl: NSURL) {
        self.sourceView = sourceView
        self.thumbImage = thumbImage
        self.imageUrl   = imageUrl
        self.image = nil
        self.imageAsset = nil
    }
    
    // 提供image初始化
    init(sourceView: UIView?,image: UIImage) {
        self.sourceView = sourceView
        self.thumbImage = nil
        self.imageUrl   = nil
        self.image = image
        self.imageAsset = nil
    }
    
    // 提供PHAsset初始化
    init(sourceView: UIView?,imageAsset: PHAsset) {
        self.sourceView = sourceView
        self.imageUrl   = nil
        self.image = nil
        self.imageAsset = imageAsset
        
        if let sourceImageView = sourceView as? UIImageView {
            self.thumbImage = sourceImageView.image
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        
        // 异步加载缩略图
        PHImageManager.default().requestImage(for: imageAsset, targetSize: CGSize.zero, contentMode: .aspectFit, options: options) { (image,_) in
            if (image != nil) {
                self.thumbImage = image
            }
        }
    }
}
