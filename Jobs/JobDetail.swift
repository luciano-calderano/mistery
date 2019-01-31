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
    
    private let dataOutput = "dd/MM/yyyy"
    private let dataOraOutput = "dd/MM/yyyy HH:mm"
    private var executionDate = Lng("exeJob") + "\n"

    override func viewDidLoad() {
        super.viewDidLoad()
        header?.header.titleLabel.text = Current.job.store.name
        checkLocationServices()
        executionDate = executionDate.replacingOccurrences(of: "$1", with: Current.job.start_date.toString(withFormat:dataOutput))
        executionDate = executionDate.replacingOccurrences(of: "$2", with: Current.job.end_date.toString(withFormat: dataOutput))
        
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
                Current.job.learning_done = true
                MYResult.shared.saveCurrentResult()
                loadAndShowResult()
                return
            }
            Current.result.estimate_date = Date().toString(withFormat: Config.DateFmt.DataJson)
            MYResult.shared.saveCurrentResult()
        }
        
        if (Current.job.notes.count > 0) {
            let ctrl = JobDetailNotes.Instance()
            ctrl.navi = navigationController!
            present(ctrl, animated: true, completion: nil)
        }
        else {
            let wheel = MYWheel()
            wheel.start(view)
            let ctrl = KpiMain.Instance()
            navigationController?.show(ctrl, sender: self)
            wheel.stop()
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
        Current.result.positioning.start_lat = MYGps.shared.lastPosition.latitude
        Current.result.positioning.start_lng = MYGps.shared.lastPosition.longitude
        MYResult.shared.saveCurrentResult()
        
        showData()
        setExecutionTimeButtons()
        
        MYGps.shared.start { (coo) in
            Current.result.positioning.start_lat = coo.latitude
            Current.result.positioning.start_lng = coo.longitude
            MYResult.shared.saveCurrentResult()
        }
    }
    @IBAction func stopTapped () {
        Current.result.execution_end_time = Date().toString(withFormat: Config.DateFmt.Ora)
        Current.result.positioning.end = true
        Current.result.positioning.end_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
        Current.result.positioning.end_lat = MYGps.shared.lastPosition.latitude
        Current.result.positioning.end_lng = MYGps.shared.lastPosition.longitude
        MYResult.shared.saveCurrentResult()
        showData()
        setExecutionTimeButtons()

        MYGps.shared.start { (coo) in
            Current.result.positioning.end_lat = coo.latitude
            Current.result.positioning.end_lng = coo.longitude
            MYResult.shared.saveCurrentResult()
        }
    }
    
    //MARK:- private -
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                MYGps.shared.start { (coo) in
                    print(coo)
                }
                return
            }
        } else {
            print("Location services are not enabled")
        }
        alert("Attenzione",
              message: "La geolocalizzazione deve essere attivate per effeturare le verifiche.",
              cancelBlock: nil) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func showData () {
        var verIni = Current.job.execution_date?.toString(withFormat: dataOutput) ?? ""
        var verFin = Current.job.execution_date?.toString(withFormat: dataOutput) ?? ""

        if verIni.isEmpty, Current.result.execution_start_time.count > 0 {
            verIni = Current.result.execution_date.dateConvert(fromFormat: Config.DateFmt.DataJson, toFormat: dataOutput)
            verIni += " " + Current.result.execution_start_time
        } else {
            verIni += " " + Current.job.execution_start_time
        }

        if verFin.isEmpty, Current.result.execution_end_time.count > 0 {
            verFin = Current.result.execution_date.dateConvert(fromFormat: Config.DateFmt.DataJson, toFormat: dataOutput)
            verFin += " " + Current.result.execution_end_time
        } else {
            verFin += " " + Current.job.execution_end_time
        }

        infoLabel.text =
            executionDate +
            Lng("prenot") + ": \(Current.job.booking_date.toString(withFormat: dataOutput))\n" +
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

        if Current.job.irregular == false {
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
