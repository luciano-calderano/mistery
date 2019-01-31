//
//  MYButton.swift
//  Lc
//
//  Created by Luciano Calderano on 03/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYLabel: UILabel {
    var title: String {
        get {
            return text!
        }
        set {
            text = newValue.toLang()
        }
    }
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    override internal func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    fileprivate func initialize () {
        minimumScaleFactor = 0.75
        adjustsFontSizeToFitWidth = true
        font = UIFont.size(font.pointSize)
        if let text = text {
            title = text
        }
    }
}
