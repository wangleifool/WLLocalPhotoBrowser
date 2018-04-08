//
//  UIColorExtension.swift
//  LikeUber
//
//  Created by lei wang on 2018/4/3.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import Foundation

extension UIColor {
    
    // 创建带有透明度，灰色
    class func createBtBackgroundColor() -> UIColor {
        return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 0.1)
    }
    
    // 创建透明度渐变背景
    class func createGradualChangingBackgroundColor(view: UIView, incresing: Bool) -> CAGradientLayer {
        //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        //  创建渐变色数组，需要转换为CGColor颜色
        let fromColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        let toColor   = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        gradientLayer.colors =  [fromColor,toColor]
       
        //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
        if incresing {
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        }
        
        //  设置颜色变化点，取值范围 0.0 ~ 1.0
        gradientLayer.locations = [0,1];
        
        return gradientLayer;
    }
}
