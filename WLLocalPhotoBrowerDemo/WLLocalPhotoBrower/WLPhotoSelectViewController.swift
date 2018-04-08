//
//  WLPhotoSelectViewController.swift
//  LikeUber
//
//  Created by lei wang on 2018/1/23
//  Copyright © 2018年 lei wang. All rights reserved.

import UIKit
import SnapKit
import Photos

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height



let numPhotoPerLine:CGFloat = 4.0
let heightAllAlbumsTableView = 400.0
let heightForAlbumTableViewCellImage:CGFloat = 44.0
let heightForAlbumTableViewCell:CGFloat      = 64.0

let maxSelectPhotoNum = 9  // 最多可以选择的照片数量

var justReachMaxNum: Bool = false

let showAllAlbumTitle = "轻触更改相册 "
let hideAllAlbumTitle = "轻触这里收起 "

let imageCollectionReusableIdentifier = "PhotoSelectCell"


private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

protocol WLPhotoSelectViewControllerDelegate {
    func afterDoneGetImages(images: Array<UIImage>)
}

class WLPhotoSelectViewController: UIViewController {
    
    var delegate: WLPhotoSelectViewControllerDelegate?
    
    // 媒体库
    var allAvailableAlbums: PHFetchResult<PHAssetCollection>!
    var allAvailableAlbumsArray: NSMutableArray! = NSMutableArray()
    var allAlbumsPhotoAssets: NSMutableArray! = NSMutableArray()
    var avaliableSmartAlbum = ["相机胶卷","全景照片","个人收藏","最近添加","屏幕截图","Camera Roll","Panoramas","Favorite","Recently Added","Screenshots"]
    var assetManager = PHCachingImageManager()
    var currentAlbumIndex: Int = 0  // 默认相册为0
    
    var currentAlbumPhotoAsset: PHFetchResult<PHAsset>?
    var currentAlbumPhotoImages = NSMutableArray()
    
    // 转场动画相关
    var transitionAnimator : ARNTransitionAnimator!
    
    lazy var allAlbumsTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.headerView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0) //默认隐藏
        })
        return tableView
    }()
    
    // 选择的照片
    var selectedPhotoIndex = Array<Int>()
    
    var backgroundCancelButton: UIButton?
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var showAlbumsHintLabel: UILabel!
    @IBOutlet weak var btTitle: UIButton!
    @IBOutlet weak var btDone: UIButton!
    @IBOutlet weak var selectNumImageView: UIImageView!
    @IBOutlet weak var btCancel: UIButton!
    
    @IBOutlet weak var btPreview: UIButton!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var photoCollectionLayout: UICollectionViewFlowLayout!
    
    var thumbnailSize:CGSize!
    var previousPreheatRect = CGRect.zero
    
    
    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        
        self.view.layer.cornerRadius = 8.0
        self.view.backgroundColor = UIColor.brown
        
        
        
        getAllAvailableAlbumData()
        
        configureCollectionView()
       
    }

    override func viewWillAppear(_ animated: Bool) {
        configureHeaderView()
        
        updateSelectedNumUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCachedAssets()
    }
    
    override func viewWillLayoutSubviews() {
        let StatusBarHeight: CGFloat = WLDevice.isIPhoneX() ? 44.0 : 20.0
        self.view.frame = CGRect(x: 0, y: StatusBarHeight, width: ScreenWidth, height: ScreenHeight)
        super.viewWillLayoutSubviews()
        print(self.view.frame)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetToDefault() {
                
        if self.isViewLoaded {
            selectedPhotoIndex.removeAll()
            allAlbumsTableView.delegate?.tableView!(allAlbumsTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            updateSelectedNumUI()
        }
        
    }
    
    // MARK: header View 相关
    func setShowAlbumsHintLabel(isShowed: Bool) {
        let attributeString = NSMutableAttributedString()
        let hintAttibuteString = NSAttributedString(string: (isShowed ? hideAllAlbumTitle : showAllAlbumTitle))
        attributeString.append(hintAttibuteString)
        
        let text = NSTextAttachment()
//        if let image = UIImage(named:(isShowed ? "up" : "down")) {
        if let image = isShowed ? UIImage.createUpImage() : UIImage.createDownImage() {
            text.image = image
            text.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            let attachmentAT = NSAttributedString(attachment: text)
            attributeString.append(attachmentAT)
        }
        
        showAlbumsHintLabel.attributedText = attributeString
    }
    

    
    func configureHeaderView() {
        let albumCollection = allAvailableAlbumsArray.object(at: currentAlbumIndex) as! PHAssetCollection
        self.btTitle.setTitle(albumCollection.localizedTitle, for: .normal)
        
        btCancel.setImage(UIImage.createCloseImage(), for: .normal)
        
        setShowAlbumsHintLabel(isShowed: false)
        hideAllAlbumTableView()
    }
    
    @IBAction func btDonePressed(_ sender: Any) {
        
        DispatchQueue.global().async {
            var images = Array<UIImage>()
            
            for i in self.selectedPhotoIndex {
                let asset = self.currentAlbumPhotoAsset?.object(at: i)
                
                PHImageManager.default().requestImageForAsset(asset: asset!, isSync: true, isHighQuality: true, resultHandler: { (image, _) in
                        if image != nil {
                            images.append(image!)
                        }
                })
            }
            
            print(images.count)
            if images.count != 0 {
                self.delegate?.afterDoneGetImages(images: images)
            }
            
        }
        
//        delegate?.afterDoneGetImages(images: <#T##Array<UIImage>#>)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btCancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSelectedNumUI() {
        if selectNumImageView == nil {
            return
        }
        
        let num = selectedPhotoIndex.count
        
        if num == 0 {
            selectNumImageView.image = nil
            btPreview.isEnabled = false
            btPreview.setTitleColor(UIColor.lightGray, for: .normal)
        } else if num > maxSelectPhotoNum {
            return
        } else {
            btPreview.isEnabled = true
            btPreview.setTitleColor(UIColor.black, for: .normal)
            
//            let numImageName = "num\(num)"
//            selectNumImageView.image = UIImage(named: numImageName)
            
            if let image = UIImage.createNumImage(num: num) {
                selectNumImageView.image  = image
                
                UIView.animateKeyframes(withDuration: wlAnimationTimeInterval, delay: 0, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: {
                    
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/4.0, animations: {
                        self.selectNumImageView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                    })
                    
                    UIView.addKeyframe(withRelativeStartTime: 1/4.0, relativeDuration: 1/4.0, animations: {
                        self.selectNumImageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                    })
                    
                    UIView.addKeyframe(withRelativeStartTime: 2/4.0, relativeDuration: 1/4.0, animations: {
                        self.selectNumImageView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
                    })
                    
                    UIView.addKeyframe(withRelativeStartTime: 3/4.0, relativeDuration: 1/4.0, animations: {
                        self.selectNumImageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    })
                    
                }, completion: nil)
            }            
            
            if num == maxSelectPhotoNum {
                justReachMaxNum = true  //全局变量 用来判断 达到最大和即将最大的临界值 表现
                photoCollectionView.reloadData()
            } else if justReachMaxNum {
                justReachMaxNum = false
                photoCollectionView.reloadData()
            }
            
        }
        
        
    }
    
    
    @IBAction func btPreviewPressed(_ sender: Any) {
        
        var items = Array<WLPhotoItem>()
        
        for i in selectedPhotoIndex {
            let asset: PHAsset = currentAlbumPhotoAsset?.object(at: i) as! PHAsset
            
            let newIndexPath = IndexPath(row: i, section: 0)
            let cell = photoCollectionView.cellForItem(at: newIndexPath) as? WLPhotoSelectCollectionViewCell
            
            
//            let item: KSPhotoItem = KSPhotoItem(sourceView: cell?.imageView, imageAsset:asset)
            let item = WLPhotoItem(sourceView: cell?.imageView, imageAsset: asset)
            
            items.append(item)
            
        }
        
        showPhotoBrower(photos: items, selectedIndex: 0)
    }
    
    // MARK: all albums data
    func saveDataToTempory(_ assetCollection: PHAssetCollection) {
        // 获取相册集里所有的资源
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        option.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let allAssetsInAlbum = PHAsset.fetchAssets(in: assetCollection, options: option)
        
        if allAssetsInAlbum.count == 0 {
            return
        }
        
        
        
        // 筛选过后的相册对象保存
        if assetCollection.localizedTitle == "相机胶卷" {
            allAvailableAlbumsArray.insert(assetCollection, at: 0)  //相机胶卷插入顶端
            // 每个相册的所以资源对象 保存到数组
            allAlbumsPhotoAssets.insert(allAssetsInAlbum, at: 0)
        } else {
            allAvailableAlbumsArray.add(assetCollection)
            // 每个相册的所以资源对象 保存到数组
            allAlbumsPhotoAssets.add(allAssetsInAlbum)
        }
        
        
        
    }
    
    func getAllAvailableAlbumData() {
//        let albumOption = PHFetchOptions()
//        albumOption.predicate = NSPredicate(format: "title = %@", "Camera Roll")  //NSPredicate(format: "title = %@", argumentArray: ["Camera Roll"])
        
        // 先获取智能相册
        allAvailableAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        for i in 0 ..< allAvailableAlbums.count {
            // 获取相册集
            let assetCollection = allAvailableAlbums.object(at: i)
        
            
            if !avaliableSmartAlbum.contains(assetCollection.localizedTitle!) {
                continue
            }
            
            
            
            // 保存数据到内存
            saveDataToTempory(assetCollection)
            
        }
        
        // 再获取用户创建的相册
        allAvailableAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for i in 0 ..< allAvailableAlbums.count {
            let assetCollection = allAvailableAlbums.object(at: i)
            
            saveDataToTempory(assetCollection)
        }
        
        // 一些初始化
        if allAlbumsPhotoAssets.count != 0 {
            currentAlbumPhotoAsset = allAlbumsPhotoAssets.object(at: currentAlbumIndex) as? PHFetchResult<PHAsset>
        }
        
        
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        assetManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    // 有了这个函数，缓存出来的图片尺寸才会正确
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: photoCollectionView!.contentOffset, size: photoCollectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in photoCollectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in currentAlbumPhotoAsset!.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in photoCollectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in currentAlbumPhotoAsset!.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        assetManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        assetManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    // MARK: transition animation
    func setupTransitionAniamtion(sourceVC: UIViewController) {
        var animation: interactiveTransition!
        if (sourceVC.navigationController != nil) {
            animation = interactiveTransition(sourceVC: sourceVC.navigationController!, destVC: self)
        } else {
            animation = interactiveTransition(sourceVC: sourceVC, destVC: self)
        }
        
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetView: _self.photoCollectionView, direction: .bottom)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.transitionAnimator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupTransitionAniamtion(sourceVC: sourceVC)
            }
        }
        
        
        self.transitionAnimator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        //        self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: gestureHandler)
        
        self.transitioningDelegate = self.transitionAnimator
    }
}
