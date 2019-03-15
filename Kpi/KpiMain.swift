//
//  KpiMain.swift
//  MysteryClient
//
//  Created by mac on 05/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiMain: MYViewController {
    class func Instance() -> KpiMain {
        return Instance(sbName: "Kpi", "KpiMain") as! KpiMain
    }
    static let firstPage = -1
    
    @IBOutlet private var container: UIView!
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    @IBOutlet private var warnBtn: UIButton!

    private var kpiView: KpiBaseView!
    
    var currentIndex = firstPage
    var myKeyboard: MYKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle = Current.job.store.name
        warnBtn.isHidden = (Current.job.notes.count == 0)
        view.bringSubviewToFront(warnBtn)
        
        switch currentIndex {
        case KpiMain.firstPage:
            kpiView = KpiInitView.Instance()
        case Current.job.kpis.count:
            kpiView = KpiLastView.Instance()
            nextBtn.setTitle(Lng("lastPage"), for: .normal)
        default:
            kpiView = KpiQuestView.Instance()
            kpiView.kpiIndex = currentIndex
            scroll.backgroundColor = UIColor.white
        }

        kpiView.mainVC = self
        kpiView.delegate = self
        scroll.addSubview(kpiView)
        showPageNum()
        
        myKeyboard = MYKeyboard(vc: self, scroll: scroll)
        
        for btn in [backBtn, nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        nextBtn.semanticContentAttribute = .forceRightToLeft
        nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    override func headerViewSxTapped() {
       navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var rect = kpiView.frame
        rect.size.height = kpiView.getHeight()
        rect.size.width = scroll.frame.size.width
        kpiView.frame = rect
        scroll.contentSize = rect.size
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        kpiView.checkData { (response) in
            self.validateResponse(response)
        }
    }
    
    @IBAction func prevTapped () {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func warnTapped () {
        alert("Irregolare", message: Current.job.notes)
    }
    
    //MARK: - Private
    
    private func validateResponse (_ response: KpiResultType) {
        switch response {
        case .next:
            nextKpi()
        case .last:
            sendJob()
        case .errComment:
            let max = Current.job.comment_max > 0 ? Current.job.comment_max : 999
            let s = "La lunghezza dell commento deve essere tra \(Current.job.comment_min) e \(max) caratteri"
            alert(Lng("error"), message: s)
        case .errValue:
            alert(Lng("error"), message: Lng("noValue"))
        case .errNotes:
            alert(Lng("error"), message: Lng("noNotes"))
        case .errAttch:
//            alert(Lng("error"), message: Lng("noAttch"))
            break
        case .err:
            break
        }
    }
    
    private func sendJob () {
        if let error = SendJob.send(dict: MYResult.resultDict) {
            alert ("Errore nell'invio dell'incarico", message: error, okBlock: nil)
            return
        }
        alert (Lng("readyToSend"), message: "", okBlock: {
            (ready) in
            self.navigationController!.popToRootViewController(animated: true)
        })
    }
    
    private func showPageNum() {
        if let label = header?.header.kpiLabel {
            label.isHidden = false
            label.text = "\(currentIndex + 2)/\(Current.job.kpis.count + 2)"
        }
    }
    
    private func nextKpi () {
        var idx = Current.job.kpis.count
        defer {
            let vc = KpiMain.Instance()
            vc.currentIndex = idx
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if kpiView.kpiIndex < 0 { // Incarico non svolto
            return
        }
        
        let lastKpi = Current.job.kpis.count - 1
        if currentIndex == lastKpi {
            return
        }

        let next = currentIndex + 1
        for index in next...lastKpi {
            let kpi = Current.job.kpis[index]            
            if kpi.isValid == true {
                idx = index
                return
            }
        }
    }
}

//MARK:- KpiDelegate

extension KpiMain: KpiDelegate {
    func kpiEndEditing() {
        myKeyboard.endEditing()
    }
    
    func kpiStartEditingAtPosY(_ y: CGFloat) {
        myKeyboard.startEditing(y: y)
    }
}
