//
//  UIFontExtension.swift
//  Kanito
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
enum FontType: String {
    case Bold
    case Light
    case Regular
}


extension UIFont {
    class func size(_ size: CGFloat, type: FontType = FontType.Regular) -> UIFont {
        return self.mySize(size, type: type)
    }

    class func mySize(_ size: CGFloat, type: FontType = FontType.Regular) -> UIFont {
        switch type {
        case .Bold:
            return UIFont.boldSystemFont(ofSize: size);
        default:
            break
        }
        return UIFont.systemFont(ofSize: size);
    }
}
