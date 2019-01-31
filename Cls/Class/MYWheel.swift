//
//  MYWheel.swift
//  Lc
//
//  Created by Luciano Calderano on 10/11/16.
//  Copyright © 2016 it.kanitoKanito. All rights reserved.
//

import UIKit

class MYWheel: UIView {
    let activityIndicatorView = UIActivityIndicatorView()
    init(_ start: Bool = false) {
        super.init(frame: UIScreen.main.bounds)
        self.initialize()
        if start {
            self.start()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initialize () {
        self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.1) //UIColor.clearColor()
        let activityIndicatorContainer: UIView = UIView()
        activityIndicatorContainer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicatorContainer.center = self.center
        activityIndicatorContainer.backgroundColor = UIColor.darkGray
        activityIndicatorContainer.alpha = 0.9
        activityIndicatorContainer.clipsToBounds = true
        activityIndicatorContainer.layer.cornerRadius = 10
        
        activityIndicatorView.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicatorView.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicatorView.center = CGPoint(x: activityIndicatorContainer.frame.size.width / 2,
                                               y: activityIndicatorContainer.frame.size.height / 2)
        
        activityIndicatorContainer.addSubview(activityIndicatorView)
        
        self.addSubview(activityIndicatorContainer)
    }
    
    func stop () {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
        self.removeFromSuperview()
    }
    
    func start(_ uiView: UIView = UIApplication.shared.keyWindow!) -> Void {
        self.frame = uiView.bounds
//        self.center = uiView.center
        uiView.addSubview(self)
        activityIndicatorView.startAnimating()
    }
}
