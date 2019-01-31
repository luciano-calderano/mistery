//
//  Keyboard.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class MYKeyboard {
    private var scroll: UIScrollView?
    private var prevOffset = CGPoint.zero
//    private var vc: UIViewController!
    private var kbHeight:CGFloat = 0
    init() {
        
    }
    init(vc: UIViewController, scroll: UIScrollView? = nil) {
//        self.vc = vc
        self.scroll = scroll
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(notification:)),
                                               name:UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name:UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow (notification: NSNotification) {
        let kbSize = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        kbHeight = kbSize.cgRectValue.size.height
    }
    
    @objc func keyboardWillHide (notification: NSNotification) {
        scroll?.contentInset = UIEdgeInsets.zero
    }
    
    func endEditing() {
        scroll?.contentOffset = prevOffset
    }
    
    func startEditing(y: CGFloat) {
        if let scroll = scroll {
            scroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbHeight, right: 0)
            
            prevOffset = scroll.contentOffset
            var offset = scroll.contentOffset
            offset.y = y
            scroll.contentOffset = offset
        }
    }
}
