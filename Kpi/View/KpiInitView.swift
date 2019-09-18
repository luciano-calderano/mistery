//
//  SubText
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiInitView: KpiBaseView {
    class func Instance() -> KpiInitView {
        return InstanceView() as! KpiInitView
    }

    @IBOutlet private var undoneView: UIView!
    @IBOutlet private var jobNotDoneReason: MYTextField!
    @IBOutlet private var okButton: MYButton!
    @IBOutlet private var noButton: MYButton!
    @IBOutlet private var atchButton: MYButton!
    @IBOutlet private var datePicker: UIDatePicker!
    
    private var geoPhotoKpi = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        for btn in [okButton, noButton] {
            btn?.layer.cornerRadius = (btn?.frame.size.height)! / 2
        }
        okTapped()
        jobNotDoneReason.delegate = self
        for i in 0..<Current.job.kpis.count {
            let kpi = Current.job.kpis[i]
            if kpi.type == "geophoto" {
                geoPhotoKpi = i
                break
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        let curJob = Current.job
        var curRes = Current.result
        atchButton.layer.cornerRadius = atchButton.frame.size.height / 2
        
        if curRes.execution_date.isEmpty, let d = curJob.execution_date {
            curRes.execution_date = d.toString(withFormat: Config.DateFmt.DataJson)
        }
        if curRes.execution_start_time.isEmpty && curJob.execution_start_time.count > 4 {
            curRes.execution_start_time =  Current.job.execution_start_time.left(lenght: 5)
        }
        if curRes.execution_end_time.isEmpty && curJob.execution_end_time.count > 4 {
            curRes.execution_end_time = Current.job.execution_end_time.left(lenght: 5)
        }
        if curRes.execution_date.isEmpty == false {
            let d = curRes.execution_date + " " + curRes.execution_start_time + ":00"
            if let date = d.toDate(withFormat: Config.DateFmt.DataOraJson) {
                datePicker.date = date
            }
        }
        jobNotDoneReason.text = curRes.comment
    }
    
    override func checkData(completion: @escaping (KpiResultType) -> ()) {
        if undoneView.isHidden == false && (jobNotDoneReason.text?.isEmpty)! {
            jobNotDoneReason.becomeFirstResponder()
            completion (.errNotes)
        } else {            
            Current.result.execution_date = datePicker.date.toString(withFormat: Config.DateFmt.DataJson)
            Current.result.execution_start_time = datePicker.date.toString(withFormat: Config.DateFmt.Ora)
            MYResult.shared.saveCurrentResult()
            completion (.next)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func okTapped () {
        undoneView.isHidden = true
        atchButton.isHidden = undoneView.isHidden
        okButton.backgroundColor = UIColor.white
        noButton.backgroundColor = UIColor.lightGray
        kpiIndex = 0
    }
    
    @IBAction func noTapped () {
        undoneView.isHidden = false
        atchButton.isHidden = geoPhotoKpi < 0 ? true : undoneView.isHidden
        okButton.backgroundColor = UIColor.lightGray
        noButton.backgroundColor = UIColor.white
        kpiIndex = -1
    }
    
    @IBAction func atchTapped () {
        let  kpiAtch = KpiAtch(mainViewCtrl: mainVC)
        kpiAtch.delegate = self
        kpiAtch.showArchSelection()
    }
}

extension KpiInitView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension KpiInitView: KpiAtchDelegate {
    func kpiAtchSelectedImage(withData data: Data) {
        if geoPhotoKpi < 0 {
            return
        }
        
        currentResult = Current.result.results[geoPhotoKpi]
        currentResult.attachment = "\(Current.job.reference).\(currentKpi.id).jpg"
        let file = Current.jobPath + currentResult.attachment
        do {
            try data.write(to: URL(fileURLWithPath: file))
        } catch {
            bugsnag.sendException("errore salvataggio file " + currentResult.attachment)
            currentResult.attachment = "";
        }
    }
}
