//
//  Ext.Image.swift
//  Kanito
//
//  Created by Luciano Calderano on 07/12/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(_ maxSize: CGFloat) -> UIImage? {
        let maxOrigSize = max(self.size.width, self.size.height)
        let scale = maxSize / maxOrigSize
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        
        return resize(newSize: newSize)
    }
    
    func resize(newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        return resize(newSize: newSize)
    }
    
    func resize(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
