//
//  KpiLast.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiLastView: KpiBaseView {
    class func Instance() -> KpiLastView {
        return InstanceView() as! KpiLastView
    }
    
    @IBOutlet private var finalView: UIView!
    @IBOutlet private var finalText: UITextView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var datePicker: UIDatePicker!
    private var minmax = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if Current.result.comment.isEmpty {
            Current.result.comment = Current.job.comment
        }

        finalText.text = Current.result.comment
        finalText.layer.borderColor = UIColor.lightGray.cgColor
        finalText.layer.borderWidth = 1
        finalText.delegate = self
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if Current.job.notes.count > 0 {
            
        }
        var date = Date()
        if  Current.result.execution_date.isEmpty == false {
            let time = Current.result.execution_end_time.isEmpty ?
                Date().toString(withFormat: Config.DateFmt.Ora) : Current.result.execution_end_time
            let s = Current.result.execution_date + " " + time + ":00"
            if let d = s.toDate(withFormat: Config.DateFmt.DataOraJson) {
                date = d
            }
        }
        datePicker.date = date

        counterLabel.text = ""
        if (Current.job.comment_min == 0 && Current.job.comment_max == 0) {
            counterLabel.isHidden = true
        }
        else {
            minmax = ""
            if Current.job.comment_min > 0 {
                minmax = minmax + " Min." + String(Current.job.comment_min)
            }
            if Current.job.comment_max > 0 {
                minmax = minmax + " Max." + String(Current.job.comment_max)
            }
            counterLabel.text = minmax
        }
    }
    
    override func checkData(completion: @escaping (KpiResultType) -> ()) {
        if finalText.text.count < Current.job.comment_min {
            completion(.errComment)
            return
        }
        if Current.job.comment_max > 0 && finalText.text.count > Current.job.comment_max {
            completion(.errComment)
            return
        }
        Current.result.comment = finalText.text!
        Current.result.compiled = 1
        Current.result.compilation_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
        Current.result.execution_end_time = datePicker.date.toString(withFormat: Config.DateFmt.Ora)
        MYResult.shared.saveCurrentResult()        
        completion (.last)
    }
}

extension KpiLastView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if text != "" {
            if Current.job.comment_max > 0 && range.location >= Current.job.comment_max {
                return false
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        if counterLabel.isHidden == false {
            counterLabel.text = "\(textView.text.count)" + minmax
        }
    }
}
