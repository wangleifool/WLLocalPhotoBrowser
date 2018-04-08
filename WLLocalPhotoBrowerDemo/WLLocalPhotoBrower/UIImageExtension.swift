//
//  UIImageExtension.swift
//  LikeUber
//
//  Created by lei wang on 2018/4/3.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import Foundation

extension UIImage {
    
    class func createImage(bundleName: String, imageFullName: String) -> UIImage? {
        
        if let bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle") {
            let imagePath = bundlePath+"/"+imageFullName
            return UIImage(contentsOfFile: imagePath)
        }
        
        return nil
    }
    
    
    class func createDownImage() -> UIImage? {
        return createImage(bundleName: "WLPhotoSelectBrower", imageFullName: "down@3x.png")
    }
    
    class func createUpImage() -> UIImage? {
        return createImage(bundleName: "WLPhotoSelectBrower", imageFullName: "up@3x.png")
    }
    
    class func createPhotoSelectImage() -> UIImage? {
        return createImage(bundleName: "WLPhotoSelectBrower", imageFullName: "photoSelect@3x")
    }
    
    class func createBigPhotoSelectImage() -> UIImage? {
        return createImage(bundleName: "WLPhotoSelectBrower", imageFullName: "bigPhotoSelect@3x")
    }
    
    class func createPhotoNotSelectImage() -> UIImage? {
        return createImage(bundleName: "WLPhotoSelectBrower", imageFullName: "photoNotSelect@3x")
    }
    
    class func createBigPhotoNotSelectImage() -> UIImage? {
        return createImage(bundleName: "WLPhotoSelectBrower", imageFullName: "bigPhotoNotSelect@3x")
    }
    
    class func createCloseImage() -> UIImage? {
        return createImage(bundleName: "WLPhotoSelectBrower", imageFullName: "close@3x.png")
    }
    
    // 0 - 9
    class func createNumImage(num: Int) -> UIImage? {
        let fullName = "number"+String(num)+"@3x.png"
        return createImage(bundleName: "WLPhotoSelectBrower", imageFullName: fullName)
    }
}
