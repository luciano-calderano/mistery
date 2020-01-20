//
//  MBizHud.swift
//  INeedCashNow
//
//  Created by Developer on 30/07/2019.
//  Copyright © 2019 Mobilesoft s.r.l. All rights reserved.
//

import UIKit

public struct Loader {
    private class LoaderView: UIView {
        private var wait = UIActivityIndicatorView()
        private func initialize() {
            addSubview(wait)
            frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            wait.style = .whiteLarge
            wait.center = center
        }
        
        override func willMove(toWindow newWindow: UIWindow?) {
            if newWindow != nil, let v = superview {
                center = v.center
                wait.startAnimating()
            }
            else {
                wait.stopAnimating()
            }
        }
        
        convenience init() {
            self.init(frame: CGRect())
            initialize()
        }
    }
    
    private class BackView: UIView {
        private func initialize() {
            blurOnView(self)
        }

        private func blurOnView(_ view: UIView) {
            view.backgroundColor = .clear
            let blurFx = UIBlurEffect(style: .dark)
            let blurFxView = UIVisualEffectView(effect: blurFx)
            blurFxView.frame = view.bounds
            blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurFxView, at: 0)
        }
                
        override func willMove(toWindow newWindow: UIWindow?) {
            if newWindow != nil, let v = superview {
                frame = v.bounds
            }
        }
        
        convenience init() {
            self.init(frame: CGRect())
            initialize()
        }
    }
    
    private class MainView: UIView {
        convenience init() {
            self.init(frame: CGRect())
            backgroundColor = .clear
            addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))

            addSubview(BackView())
            addSubview(LoaderView())
        }
    }
    
    static private let mainView = MainView()
    static func start(inView: UIView? = nil) {
        if mainView.superview != nil {
            return
        }
        if let container = inView ?? (UIApplication.shared.windows.filter {$0.isKeyWindow}.first) {
            mainView.frame = container.bounds
            container.addSubview(mainView)
        }
    }
    
    static func stop() {
        if mainView.superview != nil {
            mainView.removeFromSuperview()
        }
    }
}
