//
//  WLPhtoBrowerViewController.swift
//  LikeUber
//
//  Created by lei wang on 2018/3/31.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import UIKit
import Photos

let wlAnimationTimeInterval = 0.3

let PhotoNotSelectImageString = "bigPhotoNotSelect"
let PhotoSelectImageString = "bigPhotoSelect"


enum WLDismissAnimationType {
    case slide
    case scale
}

typealias AfterDismissPhotoBrower = (_ isBtDonePressed: Bool, _ selectedIndexs: Array<Int>) -> Void

class WLPhotoBrowerViewController: UIViewController,UIViewControllerTransitioningDelegate,UIScrollViewDelegate {
    
    var afterDismissPhotoBrower: AfterDismissPhotoBrower?
    
    // 定制化
    var dismissAnimationType: WLDismissAnimationType = .scale
    
       
    
    // 所有的图片资源对象
    var items: Array<WLPhotoItem>
    var visiablePhotoViews = Array<WLPhotoView>()
    var currentPhotoIndex: Int = 0
    var allPhotosNumInTrue: Int = 0 //有时候，photobrower不会显示父级视图所有的照片，这里是记录父级视图所有图片数量的
    var selectedPhotosIndex: Array = Array<Int>()
    var photosIndex: Array = Array<Int>() //在可见照片数量和总数量不一致时，单独记录可见照片的index
    
    lazy var mainScrollView: UIScrollView = {
        let frame = self.view.bounds
        let scroll = UIScrollView(frame: frame)
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.delegate = self
        return scroll
    }()
    
    lazy var topBackgroundShapeView: UIView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100)
        let view = UIView(frame: frame)
        view.layer.addSublayer(UIColor.createGradualChangingBackgroundColor(view: view,incresing: false))
        
        return view
    }()
    
    lazy var bottomBackgroundShapeView: UIView = {
        var frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100)
        frame.origin.y = self.view.bounds.height - frame.height
        let view = UIView(frame: frame)
        view.layer.addSublayer(UIColor.createGradualChangingBackgroundColor(view: view,incresing: true))
        
        return view
    }()
    
    lazy var btDone: UIButton = {
        var frame = CGRect(x: 0, y: 8, width: 64, height: 32)
        frame.origin.x = self.view.bounds.width - frame.width
        let bt = UIButton(frame: frame)
        bt.addTarget(self, action: #selector(self.btDonePressed(sender:)), for: .touchUpInside)
        bt.setTitle("完成", for: .normal)
        bt.setTitleColor(UIColor.white, for: .normal)

//        bt.clipsToBounds = true
//        bt.layer.cornerRadius = frame.width/4
//        bt.backgroundColor = UIColor.createBtBackgroundColor()
        
        return bt
    }()
    
    lazy var btCancel: UIButton = {
        var frame = CGRect(x: 8, y: 8, width: 32, height: 32)
        let bt = UIButton(frame: frame)
        bt.setImage(UIImage.createCloseWhiteImage(), for: .normal)
        bt.addTarget(self, action: #selector(self.btCancelPressed(sender:)), for: .touchUpInside)
        
        return bt
    }()
    
    lazy var selectedNumImageView: UIImageView = {
        var frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        frame.origin.x   = self.view.bounds.width - frame.width - btDone.bounds.width + 4
        frame.origin.y   = btDone.bounds.height/2 - frame.size.height/2 + btDone.frame.origin.y
        let imageView = UIImageView(frame: frame)
        return imageView
    }()
    
    
    private lazy var pageLabel: UILabel = {
        var frame = CGRect(x: 0, y: self.view.bounds.height-40, width: self.view.bounds.width, height: 20)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()
    
    private lazy var btSelect: UIButton = {
        var frame = CGRect(x: 0, y: 0, width: 32, height: 32)
//        frame.y = self.view.bounds.height - frame.height
//        frame.x = self.view.bounds.width - frame.width
        let bt = UIButton(frame: frame)
        bt.center = CGPoint(x: self.view.bounds.width - frame.width/2 - 16, y: pageLabel.center.y)
        bt.setImage(UIImage.createBigPhotoNotSelectImage(), for: .normal)
        bt.addTarget(self, action: #selector(self.btSelectPressed(sender:)), for: .touchUpInside)
        
        return bt
    }()
    
    init(items: Array<WLPhotoItem>, selectedIndex: Int) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle   = .coverVertical
        
        currentPhotoIndex = selectedIndex
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") 
    }
    
    
    
    deinit {
        removeGesture()
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureSubviews()
        
        configureData()
        
        addGesture()
        
        
        scrollViewDidScroll(self.mainScrollView)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBackground()
        
        // 设置imageView 过渡动画效果
        let photoItem = items[currentPhotoIndex]
        if let photoView = getPhotoView(index: currentPhotoIndex) {
            photoView.imageView.image = photoItem.thumbImage
            photoView.resizeImageView()
            
            let endRect = photoView.imageView.frame
            var sourceRect: CGRect?
            if let sourceView = photoItem.sourceView {
                sourceRect = sourceView.superview?.convert(sourceView.frame, to: photoView)  // 获取souceView相对于PhotoView的坐标尺寸
            }
            
            if let rect = sourceRect {
                photoView.imageView.frame = rect   // 设置动画前，imageview的frame如sourceView一样，动画过程让他的frame变成应该有的尺寸
                
                UIView.animate(withDuration: wlAnimationTimeInterval, animations: {
                    photoView.imageView.frame = endRect
                }) { (completion: Bool) in
                    
                }
            }
        }
        
        updateSubviewsUI()        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func configureBackground() {
        self.view.backgroundColor = UIColor.black
        
        setStatusBarHidden(hidden: true)
    }

    private func configureSubviews() {
        self.view.addSubview(self.mainScrollView)
        
        // 根据照片数量，计算scrollview的contentSize和当前图片的位置
        var contentSize = self.mainScrollView.contentSize
        contentSize.width = self.mainScrollView.frame.width * CGFloat(items.count)
        self.mainScrollView.contentSize = contentSize
        self.mainScrollView.contentOffset = CGPoint(x: self.mainScrollView.frame.width*CGFloat(currentPhotoIndex), y: 0)
        
        self.view.addSubview(self.topBackgroundShapeView)
        self.view.addSubview(self.bottomBackgroundShapeView)
        self.view.addSubview(self.btCancel)
        self.view.addSubview(self.btDone)
        self.view.addSubview(self.btSelect)
        self.view.addSubview(self.selectedNumImageView)
        
        self.view.addSubview(self.pageLabel)
        updatePageLabel(page: currentPhotoIndex)
        
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    private func configureData() {
        // 只有在 需要显示的数量 和 相册的总数量不一致时，需要初始化photosIndex 数据
        if allPhotosNumInTrue != items.count {
            photosIndex = selectedPhotosIndex
        }
    }
    
    // MARK: private method
    @objc private func btCancelPressed(sender: UIButton?) {
        showDismissAnimation()
    }
    @objc private func btDonePressed(sender: UIButton?) {
        // 如果没有选中任何照片，选中done，会将本照片标记为选中，反之正常返回即可
        if selectedPhotosIndex.count == 0 {
            var currentPage = currentPhotoIndex
            if allPhotosNumInTrue != items.count {
                currentPage = photosIndex[currentPage]
            }
            selectedPhotosIndex.append(currentPage)
        }
        
        setStatusBarHidden(hidden: false)
        self.dismiss(animated: true) {
            self.afterDismissPhotoBrower?(true,self.selectedPhotosIndex)
        }
    }
    
    
    @objc private func btSelectPressed(sender: UIButton?) {
        var currentPage = currentPhotoIndex
        if allPhotosNumInTrue != items.count {
           currentPage = photosIndex[currentPage]
        }
        
        if btSelect.isSelected {
            btSelect.isSelected = false
            btSelect.setImage(UIImage.createBigPhotoNotSelectImage(), for: .normal)
            selectedPhotosIndex.remove(object: currentPage)
        } else {
            
            if selectedPhotosIndex.count == maxSelectPhotoNum {
                WLProgressHUD.showMessage(text: "最多只能选择9张图片")
                return
            }
            
            btSelect.isSelected = true
            btSelect.setImage(UIImage.createBigPhotoSelectImage(), for: .normal)
            selectedPhotosIndex.append(currentPage)
            
        }
        
        updateSelectedNumImageView(animate: true)
    }
    
    private func updateSelectButtonUI() {
        var currentPage = currentPhotoIndex
        if allPhotosNumInTrue != items.count {
            currentPage = photosIndex[currentPhotoIndex]  //photosIndex 存储的是 非全部的图片的，可被查看的图片的index，无序
        }
        
        if selectedPhotosIndex.contains(currentPage) {
            btSelect.isSelected = true
            btSelect.setImage(UIImage.createBigPhotoSelectImage(), for: .normal)
        } else {
            btSelect.isSelected = false
            btSelect.setImage(UIImage.createBigPhotoNotSelectImage(), for: .normal)
        }
    }
    
    private func updateSelectedNumImageView(animate: Bool) {
        let numSelected = selectedPhotosIndex.count
        
        if numSelected == 0 {
            selectedNumImageView.image = nil
        } else if (numSelected > maxSelectPhotoNum) {
            
        } else {
//            let imageName = String(format: "num%lu", arguments: [numSelected])
            if let image = UIImage.createNumImage(num: numSelected) {
                selectedNumImageView.image = image
                
                // 使用key frame，让设置image具有弹性效果
                if animate {
                    UIView.animateKeyframes(withDuration: wlAnimationTimeInterval, delay: 0, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: {
                        
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/4.0, animations: {
                            self.selectedNumImageView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                        })
                        
                        UIView.addKeyframe(withRelativeStartTime: 1/4.0, relativeDuration: 1/4.0, animations: {
                            self.selectedNumImageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                        })
                        
                        UIView.addKeyframe(withRelativeStartTime: 2/4.0, relativeDuration: 1/4.0, animations: {
                            self.selectedNumImageView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
                        })
                        
                        UIView.addKeyframe(withRelativeStartTime: 3/4.0, relativeDuration: 1/4.0, animations: {
                            self.selectedNumImageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                        })
                        
                    }, completion: nil)
                }
            }
        }
    }
    
    // 进入纯净模式
    func hideSubviews() {
        btDone.isHidden = true
        btCancel.isHidden = true
        btSelect.isHidden = true
        pageLabel.isHidden = true
        selectedNumImageView.isHidden = true
        
        topBackgroundShapeView.isHidden = true
        bottomBackgroundShapeView.isHidden = true
    }
    
    func showSubviews() {
        btDone.isHidden = false
        btCancel.isHidden = false
        btSelect.isHidden = false
        pageLabel.isHidden = false
        selectedNumImageView.isHidden = false
        
        topBackgroundShapeView.isHidden = false
        bottomBackgroundShapeView.isHidden = false
    }
    
    //
    private func showDismissAnimation() {
        let item = items[currentPhotoIndex]
        let photoView = getPhotoView(index: currentPhotoIndex)
        
        hideSubviews()
        
        if item.sourceView == nil {  // 没有记录sourceView
            UIView.animate(withDuration: wlAnimationTimeInterval, animations: {
                self.view.alpha = 0
            }) { (completion) in
                if completion {
                    self.dismiss(animated: false)
                }
            }
            
            return
        }
        
        var sourceRect: CGRect?
        if let sourceView = item.sourceView {
            sourceRect = sourceView.superview?.convert(sourceView.frame, to: photoView)  // 获取souceView相对于PhotoView的坐标尺寸
        }
        
        if let rect = sourceRect {            
            UIView.animate(withDuration: wlAnimationTimeInterval, animations: {
                photoView?.imageView.frame = rect
                self.view.backgroundColor = UIColor.clear
            }) { (completion) in
                
                if completion {
                    self.dismiss(animated: false)
                }
            }
        }
        
    }
    
    private func updatePageLabel(page: Int) {
        self.pageLabel.text = String(currentPhotoIndex+1) + "/" + String(items.count)
    }
    
    private func setStatusBarHidden(hidden: Bool) {
        let window = UIApplication.shared.keyWindow
        if hidden {
            window?.windowLevel = UIWindowLevelStatusBar + 1
        } else {
            window?.windowLevel = UIWindowLevelNormal
        }
    }
    
    // dismiss 之前，对souceview可见度做处理
    private func dismiss(animated: Bool) {
        let photoItem = items[currentPhotoIndex]
        
        if animated {
            UIView.animate(withDuration: wlAnimationTimeInterval) {
                photoItem.sourceView?.alpha = 1
            }
        } else {
            photoItem.sourceView?.alpha = 1
        }
        
        
        setStatusBarHidden(hidden: false)
        afterDismissPhotoBrower?(false,selectedPhotosIndex)
        
        self.dismiss(animated: false, completion: nil)
    }
    
    private func updateSubviewsUI() {
        updatePageLabel(page: currentPhotoIndex)
        updateSelectedNumImageView(animate: false)
        updateSelectButtonUI()
    }
    
    // MARK: gesture deal
    private func addGesture() {
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
        let oneTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.oneTap(gesture:)))
        oneTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(oneTapGesture)
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(gesture:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    private func removeGesture() {
        if let gestures = self.view.gestureRecognizers {
            for gesture in gestures {
                self.view.removeGestureRecognizer(gesture)
            }
        }
    }
    
    
    private func didPanGestureBegin() {
        let photoItem = items[currentPhotoIndex]
        photoItem.sourceView?.alpha = 0
        
        hideSubviews() // 隐藏其他辅助控件
    }
    
    // 处理上下滑行动画效果
    private func dealSlidePan(gesture: UIPanGestureRecognizer) {
        let photoView = getPhotoView(index: currentPhotoIndex)
        let point: CGPoint = gesture.translation(in: self.view)
        let velocity: CGPoint = gesture.velocity(in: self.view)
        
        switch gesture.state {
        case .began:
            didPanGestureBegin()
        case .changed:
            photoView?.imageView.transform = CGAffineTransform(translationX: 0, y: point.y)
            let percent = 1 - fabs(point.y)/(self.view.bounds.height/2)
            print(percent)
            self.view.backgroundColor = UIColor(white: 0, alpha: percent)
            
        case .ended:
            if (fabs(point.y) > 200 || fabs(velocity.y) > 450) {
                finishSlidePanGesture(fromPoint: point)
            } else {
                cancelPanGesture()
            }
        default:
            break
        }
    }
    
    // 处理缩放动画效果
    private func dealScalePan(gesture: UIPanGestureRecognizer) {
        let photoView = getPhotoView(index: currentPhotoIndex)
        let point: CGPoint = gesture.translation(in: self.view)
        let velocity: CGPoint = gesture.velocity(in: self.view)
        
        switch gesture.state {
        case .began:
            didPanGestureBegin()
        case .changed:
            
            var percent = 1 - fabs(point.y)/(self.view.bounds.height)
            percent = CGFloat.maximum(percent, 0) // percent 不能小于0
            let limitScale: CGFloat = CGFloat.maximum(percent,0.5) // scale 最小只能是0.5
            
            // scale 上的变化
            let scaleTransform = CGAffineTransform(scaleX: limitScale, y: limitScale)
            // 位移 上的变化
            let translateTransform = CGAffineTransform(translationX: point.x, y: point.y)
            
            // 合并两个transform
            photoView?.imageView.transform = scaleTransform.concatenating(translateTransform)
            self.view.backgroundColor = UIColor(white: 0, alpha: percent)
            
        case .ended:
            if (fabs(point.y) > 200 || fabs(velocity.y) > 450) {
                finishScalePanGesture()
            } else {
                cancelPanGesture()
            }
        default:
            break
        }
    }
    
    @objc func didPan(gesture: UIPanGestureRecognizer) {
        if let photoView = getPhotoView(index: currentPhotoIndex) {
            // 当图片处于zoom模式下，pan gesture 不做处理
            if photoView.zoomScale > CGFloat(1.0) {
                return
            }
            
            switch dismissAnimationType {
            case .slide:
                dealSlidePan(gesture: gesture)
            case .scale:
                dealScalePan(gesture: gesture)
            }
        }
    }
    
    // 处理缩放效果的 后续工作（手指离开屏幕）
    private func finishScalePanGesture() {
        showDismissAnimation()
    }
    
    // 处理滑行效果的 后续工作（手指离开屏幕）
    private func finishSlidePanGesture(fromPoint point: CGPoint) {
        let photoView = getPhotoView(index: currentPhotoIndex)
        
        let isPanToTop = (point.y < 0) ? true : false
        
        var endTranslationY: CGFloat = 0
        if isPanToTop {
            endTranslationY = 0 - self.view.bounds.height
        } else {
            endTranslationY = self.view.bounds.height
        }
        
        UIView.animate(withDuration: wlAnimationTimeInterval, animations: {
            photoView?.imageView.transform = CGAffineTransform(translationX: 0, y: endTranslationY)
            self.view.backgroundColor = UIColor.clear
        }) { (finished) in
            self.dismiss(animated: true)
        }
    }
    
    private func cancelPanGesture() {

        let photoView = getPhotoView(index: currentPhotoIndex)
        
        UIView.animate(withDuration: wlAnimationTimeInterval, animations: {
            photoView?.imageView.transform = CGAffineTransform.identity
            self.view.backgroundColor = UIColor.black
        }) { (finished) in
            self.showSubviews()
            self.setStatusBarHidden(hidden: true)
        }
    }
    
    @objc func doubleTap(gesture: UITapGestureRecognizer) {
        let photoView = getPhotoView(index: currentPhotoIndex)
        if photoView?.zoomScale == 1.0 {
            let location = gesture.location(in: self.view)
            let maxZoomScale = photoView?.maximumZoomScale;
            let width = self.view.bounds.size.width / maxZoomScale!;
            let height = self.view.bounds.size.height / maxZoomScale!;
            
            photoView?.zoom(to: CGRect(x: location.x - width/2, y: location.y - height/2, width: width, height: height), animated: true)
            
        } else {
            photoView?.setZoomScale(1.0, animated: true)
        }
    }
    
    @objc func oneTap(gesture: UITapGestureRecognizer) {
        if btDone.isHidden {
            showSubviews()
        } else {
            hideSubviews()
        }
    }
    
    private func getPhotoView(index: Int) -> WLPhotoView? {
        for photoView in self.visiablePhotoViews {
            if photoView.tag == index {
                return photoView
            }
        }
        
        return nil
    }
    
    
    
    // MARK: scrollView delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {        
        configurePhotoViews()
        removeUnvisiablePhotoViews()
    }
    
    // 移除暂时不在 三视图 循环 的PhotoView，提高性能
    private func removeUnvisiablePhotoViews() {
        if let currentPageFrame = getPhotoView(index: currentPhotoIndex)?.frame {
            var removeArray = Array<WLPhotoView>()
            for photoView in visiablePhotoViews {
                if (photoView.frame.origin.x < currentPageFrame.origin.x - currentPageFrame.width ||
                    photoView.frame.origin.x > currentPageFrame.origin.x + 2*currentPageFrame.width) {
                    
                    removeArray.append(photoView)
                    photoView.removeFromSuperview()
                }
            }
            
            
            visiablePhotoViews.removeFrom(array: removeArray)            
            
        }
    }
    
    // 刷新需要显示的photoView
    private func configurePhotoViews() {
        let scrollView = self.mainScrollView
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        
        // 使用经典的 三页面 循环重用
        for i in page-1 ... page+1 {
            if (i < 0 || i >= items.count) {
                continue
            }
            
            var photoView = getPhotoView(index: i)
            if photoView == nil {
                
                var frame = scrollView.frame
                frame.origin.x = CGFloat(i) * scrollView.frame.width // 计算photoview应该在位置
                photoView = WLPhotoView(frame: frame)
                photoView?.tag = i
                
                scrollView.addSubview(photoView!)
                visiablePhotoViews.append(photoView!)
            }
            
            if photoView?.photoItem == nil {
                photoView?.setItem(item: items[i])
            }
            
        }
        
        if page != currentPhotoIndex {
            currentPhotoIndex = page
            updateSubviewsUI()
        }
    }
    
    
    
}
