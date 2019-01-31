//
//  SubLabel.swift
//  MysteryClient
//
//  Created by mac on 29/08/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubLabel: KpiBaseSubView, UITextFieldDelegate {
    class func Instance() -> SubLabel {
        return InstanceView() as! SubLabel
    }
    override var currentResult: JobResult.KpiResult? {
        didSet {
            if let value = currentResult?.value {
                kpiLabel.text = value
            }
            delegate?.kpiViewHeight(self.frame.size.height)
        }
    }

    @IBOutlet private var kpiLabel: MYLabel!
}


