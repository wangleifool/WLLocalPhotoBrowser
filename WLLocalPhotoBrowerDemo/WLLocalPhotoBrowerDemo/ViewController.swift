//
//  ViewController.swift
//  WLLocalPhotoBrowerDemo
//
//  Created by lei wang on 2018/4/3.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController,WLPhotoSelectViewControllerDelegate {
    
    var photoSelectVC:WLPhotoSelectViewController!
    
    lazy var imageView: UIImageView = {
        let imageview = UIImageView(frame: self.view.bounds)
        return imageview
    }()
    
    lazy var button: UIButton = {
        let bt = UIButton(frame: self.view.bounds)
        bt.addTarget(self, action: #selector(self.btChooseImagePressed), for: .touchUpInside)
        return bt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.button)
        
        photoSelectVC = WLPhotoSelectViewController()
        photoSelectVC.delegate = self
        photoSelectVC.modalPresentationStyle = .overFullScreen
        photoSelectVC.setupTransitionAniamtion(sourceVC: self)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func btChooseImagePressed() {
        photoSelectVC.resetToDefault()
        self.present(photoSelectVC, animated: true, completion: nil)
    }
    
    
    func afterDoneGetImages(images: Array<UIImage>) {
        if images.count != 0 {
            self.imageView.image = images[0]
        }
    }
}
