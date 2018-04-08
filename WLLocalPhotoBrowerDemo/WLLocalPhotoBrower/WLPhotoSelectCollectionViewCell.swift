//
//  WLPhotoSelectCollectionViewCell.swift
//  LikeUber
//
//  Created by lei wang on 2018/1/24.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import UIKit


protocol WLPhotoSelectCollectionViewCellDelegate: class {
    func cellSelectStateChanged(cell: WLPhotoSelectCollectionViewCell)
}

class WLPhotoSelectCollectionViewCell: UICollectionViewCell {

    var representedIdentifier: String! //用于独立标记每个cell
    
    var coverView: UIView?
    
    var isCanSelect: Bool = true
    {
        didSet {
            if isCanSelect {
                removeCoverView()
            } else {
                addCoverView()
            }
        }
    }
    
    var isChoosed: Bool = false
    {
        didSet {
            if isChoosed {
//                btSelect.setImage(UIImage(named:"photoSelect"), for: .normal)
                btSelect.setImage(UIImage.createPhotoSelectImage(), for: .normal)
            } else {
                btSelect.setImage(UIImage.createPhotoNotSelectImage(), for: .normal)
            }
        }
    }
    
    weak var delegate: WLPhotoSelectCollectionViewCellDelegate?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btSelect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btSelect.setImage(UIImage.createPhotoNotSelectImage(), for: .normal)
    }

    
    func addCoverView() {
        removeCoverView()
        
        coverView = UIView(frame: self.bounds)
        coverView!.backgroundColor = UIColor.black
        coverView!.alpha = 0.5
        
        self.addSubview(coverView!)
    }
    
    func removeCoverView() {
        coverView?.removeFromSuperview()
    }
    
    @IBAction func photoSelectClicked(_ sender: Any) {
        
        if self.isChoosed {
            self.isChoosed = false
        } else {
            self.isChoosed = true
            
        }
        
        delegate?.cellSelectStateChanged(cell: self)
        
    }
}
