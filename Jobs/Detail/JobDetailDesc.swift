//
//  JobDetailDesc.swift
//  MysteryClient
//
//  Created by mac on 28/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobDetailDesc: UIView {
    class func Instance() -> JobDetailDesc {
        return InstanceView() as! JobDetailDesc
    }
    
    @IBOutlet var jobDesc: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var desc = Current.job.description
        if Current.job.additional_description.isEmpty == false {
            desc += "\n\n- Descrizione aggiuntiva\n\n" + Current.job.additional_description + "\n\n"
        }
        if Current.job.details.isEmpty == false {
            desc += "\n\n- Dettagli orario\n\n" + Current.job.details + "\n\n"
        }
        jobDesc.text = desc
    }
    
    @IBAction func okTapped () {
        self.removeFromSuperview()
    }
}
