//
//  WLPhotoSelectViewController-AllAlbumsTableView.swift
//  LikeUber
//
//  Created by lei wang on 2018/3/7.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import Foundation
import Photos

extension WLPhotoSelectViewController :UITableViewDelegate,UITableViewDataSource {
    
    // MARK: 所有相册的列表相关
    func addBackgroundCancelButton() {
        backgroundCancelButton = UIButton(frame: self.view.bounds)
        backgroundCancelButton!.backgroundColor = UIColor.black
        backgroundCancelButton!.alpha = 0
        backgroundCancelButton!.addTarget(self, action: #selector(self.backgroundCancelButtonClick), for: .touchUpInside)
        self.view.addSubview(backgroundCancelButton!)
        
        self.view.bringSubview(toFront: self.allAlbumsTableView)
        self.view.bringSubview(toFront: self.headerView)
    }
    
    @objc func backgroundCancelButtonClick() {
        hideAllAlbumTableView()
    }
    
    func showAllAlbumTableView() {
        setShowAlbumsHintLabel(isShowed: true)
        
        addBackgroundCancelButton()
        
        
        UIView.animate(withDuration: 0.2) {
            
            self.allAlbumsTableView.snp.remakeConstraints { (make) in
                make.top.equalTo(self.headerView.snp.bottom)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(heightAllAlbumsTableView) //默认隐藏
            }
            
            self.backgroundCancelButton?.alpha = 0.5
            
            //用来立即刷新布局（不写无法实现动画移动，会变成瞬间移动）
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    func hideAllAlbumTableView() {
        setShowAlbumsHintLabel(isShowed: false)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.allAlbumsTableView.snp.remakeConstraints { (make) in
                make.top.equalTo(self.headerView.snp.bottom)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(0) //默认隐藏
            }
            
            self.backgroundCancelButton?.alpha = 0
            
            self.view.layoutIfNeeded()
        }) { (isComplete) in
            self.backgroundCancelButton?.removeFromSuperview()
        }
        
    }
    
    @IBAction func btChangeAlbumClick(_ sender: Any) {
        if let bt = sender as? UIButton {
            if bt.tag == 0 {
                bt.tag = 1
                showAllAlbumTableView()
            } else {
                bt.tag = 0
                hideAllAlbumTableView()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAvailableAlbumsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "albumsCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "albumsCell")
        }
        
        let assetCollection: PHAssetCollection = allAvailableAlbumsArray.object(at: indexPath.row) as! PHAssetCollection
        let allAssetsInCollection: PHFetchResult<PHAsset> = allAlbumsPhotoAssets.object(at: indexPath.row) as! PHFetchResult
        
        cell!.textLabel?.text = assetCollection.localizedTitle
        cell!.detailTextLabel!.text = String(allAssetsInCollection.count)
        cell!.accessoryType = (currentAlbumIndex == indexPath.row) ? .checkmark : .none
        
        
        let asset = allAssetsInCollection.object(at: 0) //取第一张图片作为预览图
        assetManager.requestImage(for: asset, targetSize: CGSize(width: 44.0,height:44.0), contentMode: .aspectFill, options: nil) { (image, _) in
            if image != nil {
                
                cell?.imageView?.image = image
                
                // 修改cell imageview的尺寸
                let itemSize = CGSize(width: heightForAlbumTableViewCellImage, height: heightForAlbumTableViewCellImage)
                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                let imageRect = CGRect(x:0 ,y:0 ,width:itemSize.width ,height:itemSize.height)
                cell?.imageView?.image?.draw(in: imageRect)
                
                cell?.imageView?.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
            }
        }
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForAlbumTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath)
        for visiableCell in tableView.visibleCells {
            visiableCell.accessoryType = .none
        }
        cell?.accessoryType = .checkmark
        
        currentAlbumIndex = indexPath.row
        currentAlbumPhotoAsset = allAlbumsPhotoAssets.object(at: currentAlbumIndex) as? PHFetchResult<PHAsset>
        
        btTitle.setTitle(cell?.textLabel?.text, for: .normal)
        photoCollectionView.reloadData()  //刷新照片列表
        hideAllAlbumTableView()
    }
    
    
}
