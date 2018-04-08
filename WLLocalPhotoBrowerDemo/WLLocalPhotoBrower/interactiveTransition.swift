//
//  interactiveTransition.swift
//  LikeUber
//
//  Created by lei wang on 2018/1/23.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import Foundation

class interactiveTransition : TransitionAnimatable {
    
    fileprivate weak var anyVC: UIViewController!
    fileprivate weak var photoSelectVC: WLPhotoSelectViewController!
    fileprivate var endOriginY: CGFloat = 0
    
    var completion: ((Bool) -> Void)?
    
    private var containerView:UIView!
    
    
    init(sourceVC :UIViewController ,destVC :WLPhotoSelectViewController) {
        self.anyVC = sourceVC
        self.photoSelectVC   = destVC
    }
    
    // MARK: TransitionAnimatable 协议，需要实现下面的方法
    //
    func sourceVC() -> UIViewController {
        return self.anyVC
    }
    
    func destVC() -> UIViewController {
        return self.photoSelectVC
    }
    
    func prepareContainer(_ transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController) {
        
        self.containerView = containerView
        // 根据判断是present还是dismiss，决定把toVC和fromVC哪个视图放在下层
        if transitionType.isPresenting {
            containerView.addSubview(fromVC.view)
            containerView.addSubview(toVC.view)
        } else {
            containerView.addSubview(toVC.view)
            containerView.addSubview(fromVC.view)
        }
        
        fromVC.view.setNeedsLayout()
        fromVC.view.layoutIfNeeded()
        toVC.view.setNeedsLayout()
        toVC.view.layoutIfNeeded()
        
    }
    
    func willAnimation(_ transitionType: TransitionType, containerView: UIView) {
        self.setTransitionStartSetting()
        endOriginY = containerView.bounds.height
        
        if transitionType.isPresenting {
            //            self.anyVC.beginAppearanceTransition(true, animated: false)
            self.photoSelectVC.view.frame.origin.y = self.anyVC.view.frame.size.height
        } else {
            //            self.anyVC.beginAppearanceTransition(false, animated: false)
            
            //            self.anyVC.view.alpha = 0.0
        }
        
    }
    
    func updateAnimation(_ transitionType: TransitionType, percentComplete: CGFloat) {
        
        if transitionType.isPresenting {
            photoSelectVC.view.frame.origin.y = endOriginY - (endOriginY * percentComplete) + 20
            if photoSelectVC.view.frame.origin.y < 20.0 {
                photoSelectVC.view.frame.origin.y = 20.0
            }
            anyVC.view.alpha = 1.0 - (0.5 * percentComplete)
        } else {
            photoSelectVC.view.frame.origin.y = endOriginY * percentComplete
            if photoSelectVC.view.frame.origin.y < 20.0 {
                photoSelectVC.view.frame.origin.y = 20.0
            }
            anyVC.view.alpha = 0.5 * percentComplete + 0.5
        }
    }
    
    func finishAnimation(_ transitionType: TransitionType, didComplete: Bool) {
//        setTransitionFinishSetting()
        
        if transitionType.isPresenting {
            if didComplete {
//                UIApplication.shared.keyWindow?.addSubview(self.photoSelectVC.view)
                self.completion?(transitionType.isPresenting)
            } else {
                
            }
        } else {
            if didComplete {
                
//                self.photoSelectVC.view.removeFromSuperview()
                UIApplication.shared.keyWindow?.addSubview(self.anyVC.view)
//                self.completion?(transitionType.isPresenting)
                
            } else {
                
            }
        }
    }
    
    fileprivate func setTransitionStartSetting() {
//        self.photoSelectVC.photoCollectionView.isScrollEnabled = false
        self.photoSelectVC.photoCollectionView.bounces = false
    }

    fileprivate func setTransitionFinishSetting() {
//        self.photoSelectVC.photoCollectionView.isScrollEnabled = true
        self.photoSelectVC.photoCollectionView.bounces = true
    }

}

