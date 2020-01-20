//
//  LoadJob.swift
//  MysteryClient
//
//  Created by Lc on 10/05/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

class JobSelected {
    private var completionHandler: (String, String) -> Void = { error, message in }
    
    func load (_ job: Job, completion: @escaping (String, String) -> Void) {
        completionHandler = completion
        let id = String(job.id)
        
        Current.jobPath = Config.Path.docs + id + "/"
        Current.job = job
        Current.resultFile = Config.Path.result + id + "." + Config.File.plist
        
        if validWorkingPath() {
            if Current.job.kpis.count == 0 {
                downloadDetail ()
            } else {
                openJobDetail()
            }
        }
    }
    
    private func validWorkingPath() -> Bool {
        let fm = FileManager.default
        if fm.fileExists(atPath: Current.jobPath) {
            return true
        }

        do {
            try fm.createDirectory(atPath: Current.jobPath, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch let error as NSError {
            completionHandler("Unable to create WorkingPath", error.debugDescription)
        }
        return false
    }
    
    private func downloadDetail () {
        User.shared.getUserToken(completion: { (redirect_url) in
            self.loadJobDetail()
        }) {
            (errorCode, message) in
            self.completionHandler(errorCode, message)
        }
    }
    
    private func loadJobDetail () {
        let job = Current.job
        let param = [ "object" : "job", "object_id":  job.id ] as JsonDict
        let request = MYHttp(.get, param: param)
        request.load(ok: {
            (response) in
            let dict = response.dictionary("job")
            if let job = MYJob.shared.createJob(withDict: dict) {
                Current.job = job
                self.createResultWithJob()
                return
            }
            self.completionHandler("Errore lettura dettaglio incarico", "\(job.id)")
        }) {
            (errorCode, message) in
            self.completionHandler(errorCode, message)
        }
    }
    
    //MARK:- Uscita
    
    private func createResultWithJob () {
        Current.result.id = Current.job.id
        Current.result = MYResult.shared.loadCurrentResult()
        if Current.result.results.count == 0 {
            for kpi in Current.job.kpis {
                let kpiResult = kpi.result
                let result = JobResult.KpiResult()
                result.kpi_id = kpiResult.id
                result.value = kpiResult.value
                result.notes = kpiResult.notes
                result.attachment = kpiResult.attachment
                Current.result.results.append(result)
                if kpiResult.url.isEmpty == false {
                    downloadAtch(url: kpiResult.url, kpiId: kpi.id)
                }
            }
        }
        MYResult.shared.saveCurrentResult()
        openJobDetail()
    }

    private func openJobDetail () {
        Current.result = MYResult.shared.loadCurrentResult ()
        InvalidKpi.resetKeyList()
        completionHandler("", "")
    }
    
    //MARK:- Download Attachment
    
    private func downloadAtch (url urlString: String, kpiId: Int) {
        let param = [ "object" : "job", "result_attachment": Current.job.id ] as JsonDict
        let request = MYHttp(.get, param: param)

        request.loadAtch(url: urlString, ok: {
            (response) in
            do {
                let dict = try JSONSerialization.jsonObject(with: response, options: []) as! JsonDict
                print(dict)
            } catch {
                let suffix = UIImage(data: response) == nil ? "pdf" : "jpg"
                let fileName = Current.jobPath + "\(Current.job.reference).\(kpiId).\(suffix)"
                let url = URL(fileURLWithPath: fileName)
                do {
                    try response.write(to: url)
                } catch {
                    self.completionHandler ("Errore download foto", "\(Current.job.reference).\(kpiId).\(suffix)")
                }
            }
        })
    }
}
