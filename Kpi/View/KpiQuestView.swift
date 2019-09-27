//
//  SubKpi.swift
//  MysteryClient
//
//  Created by Lc on 11/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//
import UIKit

class KpiQuestView: KpiBaseView {
    class func Instance() -> KpiQuestView {
        return InstanceView() as! KpiQuestView
    }
    
    @IBOutlet private var content: UIView!
    @IBOutlet private var containerSubView: UIView!
    @IBOutlet private var atchView: UIView!
    @IBOutlet private var atchImage: UIImageView!
    @IBOutlet private var atchName: MYLabel!
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiQuestion: MYLabel!
    @IBOutlet private var kpiInstructions: MYLabel!
    @IBOutlet private var kpiAtchBtn: MYButton!
    @IBOutlet private var kpiNote: UITextView!
    @IBOutlet private var noteLabel: UILabel!
    @IBOutlet private var subViewHeight: NSLayoutConstraint!
    @IBOutlet private var noteIrregularLabel: UILabel!

    private var valueMandatoty = true
    private var kpiQuestSubView: KpiBaseSubView!
    private var kpiAtch: KpiAtch?
    
    //MARK:-
    
    override func awakeFromNib() {
        super.awakeFromNib()
        kpiNote.delegate = self
        kpiNote.layer.borderWidth = 1
        kpiNote.layer.borderColor = UIColor.lightGray.cgColor

        let tap = UITapGestureRecognizer(target: self, action: #selector(atchRemove))
        atchView.addGestureRecognizer(tap)
        atchView.isUserInteractionEnabled = true
        atchView.layer.borderColor = UIColor.lightGray.cgColor
        atchView.layer.borderWidth = 1
    }
    
    override func initialize() {
        kpiTitle.text = currentKpi.factor
        kpiQuestion.text = currentKpi.standard
        kpiInstructions.text = currentKpi.instructions
        kpiAtchBtn.isHidden = currentKpi.attachment == false && currentKpi.attachment_required == false

        noteIrregularLabel.text = currentKpi.result.irregular_note
        updateNoteTitle(note_required: currentKpi.note_required)
        updateAtchTitle(atch_required: currentKpi.attachment_required)

        kpiNote.text = currentResult.notes
        showAtch()
        
        addQuestSubview(type: currentKpi.type)
    }
    
    override func getHeight() -> CGFloat {
        
        return atchView.frame.origin.y + 100
    }

    override func checkData(completion: @escaping (KpiResultType) -> ()) {
        let responseValue = kpiQuestSubView.getValuation()
        var noteRequired = currentKpi.note_required
        var atchRequired = currentKpi.attachment_required
        var saveResult: KpiResultType {
            if currentResult.value != responseValue.value {
                InvalidKpi.resetDependenciesWithKpi(currentKpi)
            }
            
            currentResult.kpi_id = currentKpi.id
            currentResult.value = responseValue.value
            currentResult.notes = kpiNote.text
            currentResult.attachment = atchName.text!
            
            if responseValue.dependencies.count > 0 {
                InvalidKpi.updateWithResponse(responseValue)
            }
            
            MYResult.shared.saveCurrentResult()
            return .next
        }

        if currentKpi.required == true {
            if responseValue.value.isEmpty && valueMandatoty == true {
                completion (.errValue)
                return
            }
            if responseValue.notesReq == true {
                noteRequired = responseValue.notesReq
            }
            if responseValue.attchReq == true {
                atchRequired = responseValue.attchReq
            }
        }
        
        if noteRequired == true && kpiNote.text.isEmpty {
            completion (.errNotes)
            return
        }
        
        endEditing(true)
        if atchRequired == true && atchImage.image == nil {
            askNoAtch { (okSelected) in
                if okSelected  {
                    completion (saveResult)
                } else {
                    completion (.errAttch)
                }
            }
        } else {
            completion (saveResult)
        }
    }
    
    func showAtch () {
        atchImage.image = nil
        if currentResult.attachment.isEmpty == false {
            let fileName = Current.jobPath + currentResult.attachment
            let imageURL = URL(fileURLWithPath: fileName)
            if let image = UIImage(contentsOfFile: imageURL.path) {
                atchImage.image = image
            } else {
                atchImage.image = UIImage(named: "ico.warn")
            }
        }
        
        if atchImage.image == nil {
            atchView.isHidden = true
            currentResult.attachment = ""
        } else {
            atchView.isHidden = false
        }
        atchName.text = currentResult.attachment
    }
    
    @objc func atchRemove () {
        let imv = UIImageView()
        imv.backgroundColor = UIColor.lightGray
        imv.image = atchImage.image
        imv.contentMode = .scaleAspectFit
        imv.frame = UIScreen.main.bounds
        imv.layer.borderColor = UIColor.white.cgColor
        imv.layer.borderWidth = 5
        mainVC.view.addSubview(imv)
        
        func showAlert() {
            let fileName = Current.jobPath + currentResult.attachment
            mainVC.alert(Lng("atchRemove"), message: "", cancelBlock: {
                (cancel) in
                imv.removeFromSuperview()
            }) {
                (ok) in
                imv.removeFromSuperview()
                do {
                    try FileManager.default.removeItem(atPath: fileName)
                    self.currentResult.attachment = ""
                }
                catch let error as NSError {
                    bugsnag.sendException("removeItem atPath: \(error)")
                    self.currentResult.attachment = ""
                }
                self.showAtch()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showAlert()
        }
    }
    
    //MARK: - Actions
    
    @IBAction func atchButtonTapped () {
        if kpiAtch == nil {
            kpiAtch = KpiAtch(mainViewCtrl: mainVC)
            kpiAtch?.delegate = self
        }
        currentResult.attachment = "\(Current.job.reference).\(currentKpi.id).jpg"
        let file = Current.jobPath + currentResult.attachment

        kpiAtch?.showArchSelection(file: file)
    }
    
    private func askNoAtch (completion: @escaping (Bool) -> ()) {
        let alert = UIAlertController(title: Lng("noAtchTitle"),
                                      message:Lng("noAtchMsg"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Lng("no"),
                                      style: .default,
                                      handler: { (action) in
                                        completion(false)
        }))
        
        alert.addAction(UIAlertAction(title: Lng("yes"),
                                      style: .default,
                                      handler: { (action) in
                                        completion(true)
        }))
        
        mainVC.present(alert, animated: true) { }
    }
    
    //MARK: - Private
    
    private func addQuestSubview (type: String) {
        valueMandatoty = true
        subViewHeight.constant = 1
        switch type {
        case "radio", "select" :
            kpiQuestSubView = SubRadio.Instance()
        case "text" :
            kpiQuestSubView = SubText.Instance()
        case "date" :
            kpiQuestSubView = SubDatePicker.Instance(type: .date)
        case "time" :
            kpiQuestSubView = SubDatePicker.Instance(type: .time)
        case "datetime" :
            kpiQuestSubView = SubDatePicker.Instance(type: .datetime)
        case "label", "geophoto" :
            kpiQuestSubView = SubLabel.Instance()
            valueMandatoty = false
        case "multicheckbox" :
            kpiQuestSubView = SubCheckBox.Instance()
        default:
            kpiQuestSubView = KpiBaseSubView()
            valueMandatoty = false
        }
        containerSubView.addSubviewWithConstraints(kpiQuestSubView)
        kpiQuestSubView.delegate = self
        kpiQuestSubView.currentKpi = currentKpi
        kpiQuestSubView.currentResult = currentResult
    }
    
    private func updateNoteTitle (note_required: Bool) {
        noteLabel.text = (note_required) ? Lng("noteReq") : Lng("note")
    }
    private func updateAtchTitle (atch_required: Bool) {
        kpiAtchBtn.setTitle(atch_required ? Lng("jobSelAtchReq") : Lng("jobSelAtch"), for: .normal)
    }
}

//MARK: - KpiSubViewDelegate

extension KpiQuestView: KpiSubViewDelegate {
    func kpiViewHeight(_ height: CGFloat) {
        subViewHeight.constant = height
        var rect = self.frame
        rect.size.height += height
        self.frame = rect
    }
    
    func valuationSelected(_ valuation: Job.Kpi.Valuation) {
        updateNoteTitle(note_required: valuation.note_required || currentKpi.note_required)
        updateAtchTitle(atch_required: valuation.attachment_required || currentKpi.attachment_required)
    }
}

//MARK: - UITextViewDelegate

extension KpiQuestView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.kpiStartEditingAtPosY(kpiNote.frame.origin.y - 30)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.kpiEndEditing()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK:- Image picker

extension KpiQuestView: KpiAtchDelegate {
    func kpiAtchselectPhotoValid(_ isValid: Bool) {
        if isValid == false {
            bugsnag.sendException("errore salvataggio file " + currentResult.attachment)
            currentResult.attachment = "";
        }
//        currentResult.attachment = "\(Current.job.reference).\(currentKpi.id).jpg"
//        let file = Current.jobPath + currentResult.attachment
//        do {
//            try data.write(to: URL(fileURLWithPath: file))
//        } catch {
//            bugsnag.sendException("errore salvataggio file " + currentResult.attachment)
//            currentResult.attachment = "";
//        }
        showAtch()
    }
}
