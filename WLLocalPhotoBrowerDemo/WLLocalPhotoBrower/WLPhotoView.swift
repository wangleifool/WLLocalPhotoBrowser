//
//  WLPhotoView.swift
//  LikeUber
//
//  Created by lei wang on 2018/3/29.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import UIKit
import YYImage
import Photos

let WLPhotoViewMaxScale:CGFloat = 3.0  // 最大
//let WLPhotoViewMinScale:CGFloat = 0.5

class WLPhotoView: UIScrollView,UIScrollViewDelegate {

    var photoItem: WLPhotoItem!
    
    lazy var imageView: YYAnimatedImageView = {
        let imageView = YYAnimatedImageView()
        imageView.backgroundColor = UIColor.darkGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true  // 非常重要， 不然动画结束后，可能UI上的imageView并没有你希望的尺寸
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //初始化scrollview
        self.bouncesZoom = true
        self.isMultipleTouchEnabled = true // 多指触控
        self.showsHorizontalScrollIndicator = true
        self.showsVerticalScrollIndicator   = true
        
//        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        
        self.maximumZoomScale = WLPhotoViewMaxScale
        
        self.delegate = self
        
        //添加imageview
        self.addSubview(self.imageView)
        resizeImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(self.imageView)
        fatalError("init(coder:) has not been implemented")
    }
    
    // 计算imageview的合理尺寸
    func resizeImageView() {
        if imageView.image != nil {
            let imageSize: CGSize! = imageView.image?.size
            let width = imageView.frame.width
            let height = width*(imageSize.height/imageSize.width) //按照图片的宽高比例，来计算imageview的宽高
            imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            // 显示长图,显示上面
            if height > self.frame.height {
                imageView.center = CGPoint(x: self.bounds.width/2, y: height/2)
            } else {
                imageView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
            }
            
        } else {
            var frame = self.bounds
            frame.size.height = frame.width*3/4
            imageView.frame = frame
            
            imageView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        }
        
        self.contentSize = imageView.frame.size
    }
    
    func setItem(item: WLPhotoItem?) {
        self.photoItem = item
        
        if item != nil {
            if ((item?.image) != nil) {
                self.imageView.image = item?.image
                return ;
            }
            
            if item?.imageAsset != nil {
                self.imageView.image = item?.thumbImage
                
                PHImageManager.default().requestImageForAsset(asset: item!.imageAsset!, isSync: false, isHighQuality: true, resultHandler: { (image, _) in
                    
                    if image != nil {
                        self.imageView.image = image
                        self.resizeImageView()
                    } else {
                       print("下载高清图片失败")
                    }
                    
                })
            }
            
        }
        
        resizeImageView()
    }
    
    // MARK: scrollview delegate
    // 设置需要zoom的控件
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    // 当scrollview内的控件，处于缩放状态，需要及时计算该控件的位置在中心
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX: CGFloat = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        
        let offsetY: CGFloat = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        
        self.imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
