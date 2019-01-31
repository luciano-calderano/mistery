//
//  JobDetailNotes.swift
//  MysteryClient
//
//  Created by Developer on 13/09/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

class JobDetailNotes: MYViewController {
    class func Instance() -> JobDetailNotes {
        return Instance(sbName: "Jobs", "JobDetailNotes") as! JobDetailNotes
    }
    
    @IBOutlet private var notes: MYLabel!
    var navi: UINavigationController!
    
    override func viewDidLoad() {
        notes.text = Current.job.notes
    }
    
    @IBAction func okTapped () {
        dismiss(animated: false) {
            let ctrl = KpiMain.Instance()
            self.navi.show(ctrl, sender: self)
        }
    }
}
