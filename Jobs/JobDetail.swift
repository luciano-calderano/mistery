//
//  JobDetail.swift
//  MysteryClient
//
//  Created by mac on 27/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import CoreLocation

class JobDetail: MYViewController {
    class func Instance() -> JobDetail {
        return Instance(sbName: "Jobs", "JobDetail") as! JobDetail
    }
    
    @IBOutlet var infoLabel: MYLabel!
    @IBOutlet var nameLabel: MYLabel!
    @IBOutlet var addrLabel: MYLabel!
    
    @IBOutlet var descBtn: MYButton!
    @IBOutlet var alleBtn: MYButton!
    @IBOutlet var spreBtn: MYButton!
    @IBOutlet var dateBtn: MYButton!
    @IBOutlet var euroBtn: UIButton!

    @IBOutlet var contBtn: MYButton!
    @IBOutlet var tickBtn: MYButton!
    @IBOutlet var strtBtn: MYButton!
    @IBOutlet var stopBtn: MYButton!
    
    private var executionDate = Lng("exeJob") + "\n"

    override func viewDidLoad() {
        super.viewDidLoad()
        header?.header.titleLabel.text = Current.job.store.name
        checkLocationServices()
        executionDate = executionDate.replacingOccurrences(of: "$1", with: Current.job.start_date.toString(withFormat: Config.DateFmt.dataOutput))
        executionDate = executionDate.replacingOccurrences(of: "$2", with: Current.job.end_date.toString(withFormat: Config.DateFmt.dataOutput))
        
        nameLabel.text = Current.job.store.name
        addrLabel.text = Current.job.store.address

        for btn in [contBtn, tickBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(16)
            btn.setImage(ico, for: .normal)
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            btn.layer.shadowColor = UIColor.darkGray.cgColor
            btn.layer.shadowOffset = CGSize(width: 0, height: 5)
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.layer.borderWidth = 0.5
            btn.layer.shadowOpacity = 0.2
            btn.layer.masksToBounds = false
        }
        
        for btn in [strtBtn, stopBtn] as! [MYButton] {
            btn.titleLabel?.lineBreakMode = .byWordWrapping;
            btn.titleLabel?.textAlignment = .center;
        }

        showData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Current.job.learning_done == true {
            MYHud.show()
            let js = JobSelected()
            js.load(Current.job, completion: { (error, msg) in
                MYHud.hide()
                if (error.isEmpty) {
                    self.loadAndShowResult()
                } else {
                    self.alert(error, message: msg, okBlock: nil)
                }
            })
            return
        }

        loadAndShowResult()
    }
    
    // MARK: - actions
    @IBAction func euroTapped () {
        alert("Descrizione compenso", message: Current.job.fee_desc)
    }
    
    @IBAction func mapsTapped () {
        let store = Current.job.store
        _ = Maps(lat: store.latitude, lon: store.longitude, name: store.name)
    }
    
    @IBAction func descTapped () {
        let subView = JobDetailDesc.Instance()
        subView.frame = view.frame
        view.addSubview(subView)
    }
    
    @IBAction func atchTapped () {
        let subView = JobDetailAtch.Instance()
        subView.frame = view.frame
        subView.delegate = self
        view.addSubview(subView)
    }
    
    @IBAction func spreTapped () {
        openWeb(type: .bookingRemove, id: Current.job.id)
    }
    @IBAction func dateTapped () {
        openWeb(type: .bookingMove, id: Current.job.id)
    }
    
    @IBAction func contTapped () {
        if Current.result.execution_date.isEmpty {
            guard Current.job.learning_done else {
                openWeb(type: .none, urlPage:  Current.job.learning_url)
                loadAndShowResult()
                return
            }
            MYResult.shared.saveCurrentResult()
        }
        
        if (Current.job.notes.count > 0) {
            let ctrl = JobDetailNotes.Instance()
            ctrl.modalPresentationStyle = .fullScreen
            ctrl.navi = navigationController!
            present(ctrl, animated: true, completion: nil)
        }
        else {
            MYHud.show()
            let ctrl = KpiMain.Instance()
            navigationController?.show(ctrl, sender: self)
            MYHud.hide()
        }
    }
    
    @IBAction func tickTapped () {
        openWeb(type: .ticketView, id: Current.job.id)
    }
    
    @IBAction func strtTapped () {
        Current.result.execution_date = Date().toString(withFormat: Config.DateFmt.DataJson)
        Current.result.execution_start_time = Date().toString(withFormat: Config.DateFmt.Ora)
        Current.result.positioning.start_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
        Current.result.positioning.start = true
        Current.result.positioning.start_lat = MYGps.coordinate.latitude
        Current.result.positioning.start_lng = MYGps.coordinate.longitude
        MYResult.shared.saveCurrentResult()
        
        showData()
        setExecutionTimeButtons()
    }

    @IBAction func stopTapped () {
        Current.result.execution_end_time = Date().toString(withFormat: Config.DateFmt.Ora)
        Current.result.positioning.end = true
        Current.result.positioning.end_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
        Current.result.positioning.end_lat = MYGps.coordinate.latitude
        Current.result.positioning.end_lng = MYGps.coordinate.longitude
        MYResult.shared.saveCurrentResult()
        showData()
        setExecutionTimeButtons()
    }
    
    //MARK:- private -
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            return
        }
        
        alert("Attenzione",
              message: "La geolocalizzazione deve essere attivate per effeturare le verifiche.",
              cancelBlock: nil) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func showData () {
        var verIni = Current.job.execution_date?.toString(withFormat: Config.DateFmt.dataOutput) ?? ""
        var verFin = Current.job.execution_date?.toString(withFormat: Config.DateFmt.dataOutput) ?? ""

        if verIni.isEmpty, Current.result.execution_start_time.count > 0 {
            verIni = Current.result.execution_date.dateConvert(fromFormat: Config.DateFmt.DataJson, toFormat: Config.DateFmt.dataOutput)
            verIni += " " + Current.result.execution_start_time
        } else {
            verIni += " " + Current.job.execution_start_time
        }

        if verFin.isEmpty, Current.result.execution_end_time.count > 0 {
            verFin = Current.result.execution_date.dateConvert(fromFormat: Config.DateFmt.DataJson, toFormat: Config.DateFmt.dataOutput)
            verFin += " " + Current.result.execution_end_time
        } else {
            verFin += " " + Current.job.execution_end_time
        }

        infoLabel.text =
            executionDate +
            Lng("detJobTime") + ": \(Current.job.details)\n" +
            Lng("prenot") + ": \(Current.job.booking_date.toString(withFormat: Config.DateFmt.dataOutput))\n" +
            Lng("rifNum") + ": \(Current.job.reference)\n" +
            Lng("verIni") + ": \(verIni)\n" +  Lng("verEnd") + ": \(verFin)"
    }
    
    private func loadAndShowResult () {
        setExecutionTimeButtons()
        var title = "kpiInit"
        defer {
            contBtn.setTitle(Lng(title), for: .normal)
        }
        
        if  Current.result.execution_date.isEmpty == false {
            title = "kpiCont"
            return
        }
        if Current.job.irregular == true {
            title = "kpiIrre"
            return
        }
        if Current.job.learning_done == false {
            title = "learning"
            return
        }
    }
    
    private func setExecutionTimeButtons () {
        stopBtn.isEnabled = false
        stopBtn.backgroundColor = .lightGray
        stopBtn.setTitleColor(UIColor.black, for: .normal);
        strtBtn.isEnabled = false
        strtBtn.backgroundColor = .lightGray
        strtBtn.setTitleColor(UIColor.black, for: .normal);

        if Current.job.irregular {
            return
        }
        
        if Current.result.positioning.start == false {
            strtBtn.isEnabled = true
            strtBtn.backgroundColor = UIColor.red
            strtBtn.setTitleColor(UIColor.white, for: .normal)
            return
        }
        
        if Current.result.positioning.end == false {
            stopBtn.setTitleColor(UIColor.white, for: .normal)
            stopBtn.backgroundColor = UIColor.darkGray
            stopBtn.isEnabled = true
        }
    }
}

extension JobDetail {
    private func openWeb (type: WebPage.WebPageEnum, id: Int = 0, urlPage: String = "") {
        let ctrl = WebPage.Instance(type: type, id: id)
        if urlPage.isEmpty == false {
            ctrl.page = urlPage
        }
        navigationController?.show(ctrl, sender: self)        
    }
}

// MARK: - Attachment delegate

extension JobDetail: JobDetailAtchDelegate {
    func openFileFromUrlWithString(_ page: String) {
        openWeb(type: .none, urlPage: page)
    }
}
