//
//  KpiRadio.swift
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubRadio: KpiBaseSubView {
    class func Instance() -> SubRadio {
        return InstanceView() as! SubRadio
    }
    
    @IBOutlet var tableView: UITableView!
    let rowHeight:CGFloat = 50
    var valuationSelected: Job.Kpi.Valuation?
    
    override var currentResult: JobResult.KpiResult? {
        didSet {
            if let value = currentResult?.value {
                let index = Int(value)
                for item in currentKpi.valuations {
                    if item.id == index {
                        valuationSelected = item
                        break
                    }
                }
            }
            tableView.reloadData()
            
            var rect = self.frame
            rect.size.height = self.rowHeight * CGFloat(currentKpi.valuations.count)
            self.frame = rect
            delegate?.kpiViewHeight(rect.size.height)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        SubRadioCell.register(tableView: tableView)
    }
    
    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        if let item = valuationSelected {
            response.value = "\(item.id)"
            response.notesReq = item.note_required
            response.attchReq = item.attachment_required
            response.dependencies = item.dependencies
        }
        return response
    }
}

// MARK: - UITableViewDataSource

extension SubRadio: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        valuationSelected = currentKpi.valuations[indexPath.row]
        tableView.reloadData()
        delegate?.valuationSelected(valuationSelected!)
    }
}

// MARK: - UITableViewDataSource

extension SubRadio: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentKpi.valuations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SubRadioCell.dequeue(tableView, indexPath)
        let item = currentKpi.valuations[indexPath.row]
        cell.valuationTitle.text = item.name
        
        let selected = (self.valuationSelected != nil && self.valuationSelected?.id == item.id)
        cell.selectedView.isHidden = !selected
        return cell
    }
}

// MARK: - SubRadioCell

class SubRadioCell: UITableViewCell {
    class func register (tableView: UITableView) {
        let id = String (describing: self)
        let nib = UINib(nibName: id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: id)
    }
    class func dequeue (_ tableView: UITableView, _ indexPath: IndexPath) -> SubRadioCell {
        return tableView.dequeueReusableCell(withIdentifier: "SubRadioCell", for: indexPath) as! SubRadioCell
    }

    @IBOutlet var selectView: UIView!
    @IBOutlet var selectedView: UIView!
    @IBOutlet var valuationTitle: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectView.layer.borderWidth = 1
        self.selectView.layer.borderColor = UIColor.lightGray.cgColor
        self.selectView.layer.cornerRadius = self.selectView.frame.height / 2
        self.selectedView.layer.cornerRadius = self.selectedView.frame.height / 2
    }
}


