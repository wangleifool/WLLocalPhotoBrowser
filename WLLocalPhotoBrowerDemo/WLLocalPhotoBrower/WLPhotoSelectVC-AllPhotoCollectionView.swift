//
//  WLPhotoSelectVC-AllPhotoCollectionView.swift
//  LikeUber
//
//  Created by lei wang on 2018/3/7.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import Foundation
import Photos

extension WLPhotoSelectViewController : UICollectionViewDataSource,UICollectionViewDelegate,WLPhotoSelectCollectionViewCellDelegate {
    
    func createPhotoItem(index: Int) -> WLPhotoItem {
        let asset: PHAsset = currentAlbumPhotoAsset?.object(at: index) as! PHAsset
        
        let newIndexPath = IndexPath(row: index, section: 0)
        let cell = photoCollectionView.cellForItem(at: newIndexPath) as? WLPhotoSelectCollectionViewCell
        
        return WLPhotoItem(sourceView: cell?.imageView, imageAsset: asset)
    }
    
    // MARK: collection view data source
    func configureCollectionView() {
        let cellWidth = (self.photoCollectionView.bounds.size.width - (numPhotoPerLine-1)*2) / numPhotoPerLine
        photoCollectionLayout.itemSize = CGSize.init(width: cellWidth, height: cellWidth)
        photoCollectionLayout.minimumLineSpacing = 2
        photoCollectionLayout.minimumInteritemSpacing = 2
        photoCollectionLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: cellWidth*scale, height: cellWidth*scale)
        
        photoCollectionView.register(UINib.init(nibName: "WLPhotoSelectCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: imageCollectionReusableIdentifier)
        photoCollectionView.bounces = false
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentAlbumPhotoAsset == nil {
            return 0
        }
        
        return currentAlbumPhotoAsset!.count                
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = currentAlbumPhotoAsset?.object(at: indexPath.row)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCollectionReusableIdentifier, for: indexPath) as! WLPhotoSelectCollectionViewCell
        
        if (cell.delegate == nil) {
            cell.delegate = self
        }
        
        // 判断是否可选
        if selectedPhotoIndex.count >= maxSelectPhotoNum {
            
            if selectedPhotoIndex.contains(indexPath.row) {
                cell.isCanSelect = true
            } else {
                cell.isCanSelect = false
            }
            
        } else {
            cell.isCanSelect = true
        }
        
        if selectedPhotoIndex.contains(indexPath.row) {
            cell.isChoosed = true
        } else {
            cell.isChoosed = false
        }
        
        // 获取照片
        cell.representedIdentifier = asset?.localIdentifier
//        let requestOption = PHImageRequestOptions()
//        requestOption.resizeMode = .fast
//        var rect = CGRect.zero
//        rect.size = photoCollectionLayout.itemSize
//        requestOption.normalizedCropRect = rect
        
        assetManager.requestImage(for: asset!, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
            if cell.representedIdentifier == asset?.localIdentifier && image != nil {
                cell.imageView.image = image                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView .deselectItem(at: indexPath, animated: false)
        
        var items = Array<WLPhotoItem>()
        var selectedIndex: Int = 0
        
        // 已经是最大选择数目
        if selectedPhotoIndex.count >= maxSelectPhotoNum {
            
            if selectedPhotoIndex.contains(indexPath.row) {
                for i in selectedPhotoIndex {
                    items.append(createPhotoItem(index: i))
                }
                
                selectedIndex = selectedPhotoIndex.index(of: indexPath.row)!//图片查看器的最先显示的图片的index
                
            } else {
                WLProgressHUD.showMessage(text: "最多只能选择9张图片")
                return   // 已经选择了最大数，点击非选择图片，不做响应
            }
            
        } else {
            
            selectedIndex = indexPath.row  //图片查看器的最先显示的图片的index
            
//            items = Array<WLPhotoItem>.init(repeating: WLPhotoItem(), count: currentAlbumPhotoAsset!.count)
//
//            // 先装 3张图片，立即显示
//            if selectedIndex-1 >= 0 {
//                items[selectedIndex-1] = createPhotoItem(index: selectedIndex-1)
//            }
//
//            items[selectedIndex] = createPhotoItem(index: selectedIndex)
//
//            if selectedIndex+1 < currentAlbumPhotoAsset!.count {
//                items[selectedIndex+1] = createPhotoItem(index: selectedIndex+1)
//            }
            
            // 异步加载所有的照片
//            DispatchQueue.global().async {
//                var asyncTempItems = Array<WLPhotoItem>()
                for i in 0 ..< self.currentAlbumPhotoAsset!.count {
                    items.append(self.createPhotoItem(index: i))
                }
                
//                self.photoBrowser?.items = asyncTempItems
//            }
            
            
        }
        
        
        showPhotoBrower(photos: items, selectedIndex: selectedIndex)

    }
    
    func showPhotoBrower(photos: Array<WLPhotoItem>, selectedIndex: Int) {
        
        
        let photoBrowser = WLPhotoBrowerViewController(items: photos, selectedIndex: selectedIndex)
        
        photoBrowser.allPhotosNumInTrue = (currentAlbumPhotoAsset?.count)!
        photoBrowser.selectedPhotosIndex = selectedPhotoIndex
        photoBrowser.afterDismissPhotoBrower = {(isBtDonePressed: Bool, selectedIndexs: Array<Int>) in
            self.selectedPhotoIndex = selectedIndexs
            
            if isBtDonePressed {
                self.btDonePressed(self.btDone)
            } else {
                self.photoCollectionView.reloadData()
                self.updateSelectedNumUI()
            }
        }
        self.present(photoBrowser, animated: false, completion: nil)
        
    }
    
   
    // MARK: collecion layout 布局
    
    
    // MARK: cell selected delegate
    func cellSelectStateChanged(cell: WLPhotoSelectCollectionViewCell) {
        if let selectIndex = photoCollectionView.indexPath(for: cell)?.row {
            if cell.isChoosed {
                selectedPhotoIndex.append(selectIndex)
            } else {
                selectedPhotoIndex.remove(object: selectIndex)
            }
            
            updateSelectedNumUI() //刷新UI                        
        }
    }
    
}
