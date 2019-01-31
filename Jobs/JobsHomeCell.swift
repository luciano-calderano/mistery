//
//  HomeCell.swift
//  MysteryClient
//
//  Created by Lc on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

protocol JobsHomeCellDelegate {
    func mapTapped (_ sender: JobsHomeCell, job: Job)
}

class JobsHomeCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, _ indexPath: IndexPath) -> JobsHomeCell {
        return tableView.dequeueReusableCell(withIdentifier: "JobsHomeCell", for: indexPath) as! JobsHomeCell
    }

    var job: Job! {
        didSet {
            update ()
        }
    }
    var delegate: JobsHomeCellDelegate?
    
    @IBOutlet private var name: MYLabel!
    @IBOutlet private var address: MYLabel!
    @IBOutlet private var rif: MYLabel!
    @IBOutlet private var day: MYLabel!
    @IBOutlet private var month: MYLabel!
    @IBOutlet private var warn: MYLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func update () {
        name.text = job.store.name
        address.text = job.store.address
        rif.text = "Rif. " + job.reference
        day.text = job.estimate_date.toString(withFormat: "dd")
        month.text = job.estimate_date.toString(withFormat: "MMM")
        warn.isHidden = job.irregular == false
    }
    
    @IBAction func mapTapped () {
        delegate?.mapTapped(self, job: job)
    }
}

