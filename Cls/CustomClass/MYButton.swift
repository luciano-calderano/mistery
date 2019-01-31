//
//  MYButton.swift
//  Kanito
//
//  Created by Luciano Calderano on 03/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYButton: UIButton {
    @IBInspectable var borderColor: UIColor = UIColor.clear  {
        didSet {
            layer.borderWidth = 1
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat = 3 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    var title: String {
        get { return titleLabel!.text! }
        set { self.setTitle(newValue.toLang(), for: UIControl.State()) }
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize () {
        layer.masksToBounds = false
        
        showsTouchWhenHighlighted = true
        if titleColor(for: .normal) == nil {
            setTitleColor(UIColor.white, for: UIControl.State.normal)
        }
        if let lbl = titleLabel {
            lbl.font = UIFont.size(lbl.font.pointSize)
        }
        title = currentTitle ?? ""
    }
}
