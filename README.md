# WLLocalPhotoBrowser

# 简介
一个本地相册照片浏览器，你可以预览、多选、获取照片等等操作，支持iCloud照片。 界面以及动画效果，类似于今日头条的照片选择器。


# 依赖的第三方
目前依赖YYWebImage、SnapKit和MBProgressHUD第三方框架

# 使用方法
var photoSelectVC:WLPhotoSelectViewController!

// 初始化

photoSelectVC = WLPhotoSelectViewController()
photoSelectVC.delegate = self
photoSelectVC.setupTransitionAniamtion(sourceVC: self)

// 显示

@objc func btChooseImagePressed() {
    photoSelectVC.showFrom(VC: self)
}

// 遵循WLPhotoSelectViewControllerDelegate的回调

func afterDoneGetImages(images: Array<UIImage>) {
    if images.count != 0 {
        self.imageView.image = images[0]
    }
}
