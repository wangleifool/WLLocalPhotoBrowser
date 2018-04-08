//
//  PHImageManagerExtension.swift
//  LikeUber
//
//  Created by lei wang on 2018/3/31.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import Foundation
import Photos

extension PHImageManager {
    
    
    func requestImageForAsset(asset: PHAsset, isSync: Bool, isHighQuality: Bool, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) {
        let options = PHImageRequestOptions()
        
        if isHighQuality {
            options.deliveryMode = .highQualityFormat
        } else {
            options.deliveryMode = .fastFormat
        }
        
        if isSync {
            options.isSynchronous = true
        }
        
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: resultHandler)
    }
    
}
