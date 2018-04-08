//
//  WLProgressHUD.swift
//  LikeUber
//
//  Created by lei wang on 2018/3/27.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import UIKit

// 封存常用的几个模式
enum WLProgressHUDStatus {
    case Success
    case Failure
    case Waiting
    case Info
}

let iPadTextSize: CGFloat = 1.6
let iPhoneTextSize: CGFloat = 1.2

final class WLProgressHUD: MBProgressHUD {

    // 生成单例，默认在顶层window上显示 HUD
    static let sharedWLProgressHUD = WLProgressHUD(view: UIApplication.shared.keyWindow!)
    private override init(view: UIView) {
        super.init(view: view)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")        
    }
    
    /** 在 window 上添加一个 HUD */
//    static func show(status: WLProgressHUDStatus, text: String) {
//        let sharedHUD = WLProgressHUD.sharedWLProgressHUD
//        sharedHUD?.show(true)
//        sharedHUD?.labelText = text
//        sharedHUD?.removeFromSuperViewOnHide = true
//
//
//    }
    
    open class func showMessage(text: String) {
        let sharedHUD: WLProgressHUD = WLProgressHUD.sharedWLProgressHUD
        sharedHUD.show(animated: true)
        sharedHUD.label.text = text
        sharedHUD.removeFromSuperViewOnHide = true
        sharedHUD.mode = .text
        sharedHUD.minSize = CGSize.zero
        sharedHUD.animationType = .zoom
        sharedHUD.isUserInteractionEnabled = false

//        if WLDevice.isIPad {
//            sharedHUD.label.font = UIFont.boldSystemFont(ofSize: iPadTextSize)
//        } else {
//            sharedHUD.label.font = UIFont.boldSystemFont(ofSize: iPhoneTextSize)
//        }
        
        UIApplication.shared.keyWindow?.addSubview(sharedHUD)
        sharedHUD.hide(animated: true, afterDelay: 1)
        
    }
}
