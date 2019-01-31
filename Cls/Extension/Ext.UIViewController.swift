//
//  JsonDictExtension.swift
//  Lc
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

extension UIViewController {
    class func Instance(sbName: String, _ id: String = "", isInitial: Bool = false) -> UIViewController {
        let sb = UIStoryboard(name: sbName, bundle: nil)
        if isInitial {
            return sb.instantiateInitialViewController()!
        } else {
            let ctrlId = id.isEmpty ? String (describing: self) : id
            return sb.instantiateViewController(withIdentifier: ctrlId)
        }
    }

    func alert (_ title:String, message: String, cancelBlock:((UIAlertAction) -> Void)?, okBlock:((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: cancelBlock))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okBlock))

        present(alert, animated: true, completion: nil)
    }

    func alert (_ title:String, message: String, okBlock:((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title as String, message: message  as String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okBlock))
        
        present(alert, animated: true, completion: nil)
    }
}

