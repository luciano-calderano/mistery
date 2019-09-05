//
//  MBizHud.swift
//  INeedCashNow
//
//  Created by Developer on 30/07/2019.
//  Copyright © 2019 Mobilesoft s.r.l. All rights reserved.
//

import UIKit

@objc class MYHud: UIViewController {
    private static var hud: MYHud?
    @objc class func show () {
        if hud == nil {
            hud = MYHud()
            hud!.show()
        }
    }
    @objc class func hide () {
        hud?.hide()
        hud = nil
    }
    private var window: UIWindow!
    
    func show () {
        window = createNewWindow()
        window.rootViewController!.present(self, animated: false, completion: nil)
    }
    
    func hide () {
        window.resignKey()
        window.isHidden = true
        window.removeFromSuperview()
        window.windowLevel = UIWindow.Level.alert - 1
        window.setNeedsLayout()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        view.frame = UIScreen.main.bounds
        
        let backColor = UIView()
        view.addSubview(backColor)
        backColor.backgroundColor = .black
        backColor.alpha = 0.33
        backColor.frame = view.bounds
        
        let hud = UIActivityIndicatorView()
        view.addSubview(hud)
        hud.style = UIActivityIndicatorView.Style.whiteLarge
        hud.center = view.center
        hud.startAnimating()
    }
    
    private func createNewWindow() -> UIWindow {
        let ctrl = UIViewController()
        ctrl.view.backgroundColor = .clear
        ctrl.providesPresentationContextTransitionStyle = true
        ctrl.definesPresentationContext = true
        ctrl.modalPresentationStyle = .overCurrentContext
        ctrl.modalTransitionStyle = .crossDissolve
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ctrl
        window.windowLevel = UIWindow.Level.alert + 1
        window.makeKeyAndVisible()
        return window
    }
 }
