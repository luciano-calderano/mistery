//
//  SendJob.swift
//  MysteryClient
//
//  Created by Lc on 10/05/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class MySend {
    private var textLog = ""
    private let jobId = String(Current.job.id)
    private let wheel = MYWheel()

    private var mainVC: UIViewController!
    private func appendLog (_ txt: String) {
        textLog += Date().toString(withFormat: Config.DateFmt.DataOraJson) + " -> " + txt + "\n"
    }
    
    func sendResult (fromVC ctrl: UIViewController) {
        mainVC = ctrl
        textLog = ""
        wheel.start(mainVC.view)
        appendLog("Start")

        if createZip() {
            startUpload()
        }
        else {
            errore()
        }
    }
    
    private func createZip() -> Bool {
        let fm = FileManager.default
        var jsonData = Data()
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: MYResult.resultDict, options: .prettyPrinted)
        } catch {
            appendLog("JSONSerialization: error")
            return false
        }
        
        do {
            try jsonData.write(to: URL(fileURLWithPath: Current.jobPath + Config.File.json))
        } catch {
            appendLog("json.write: error")
            return false
        }
        
        var filesToZip = [URL]()
        do {
            filesToZip = try fm.contentsOfDirectory(at: URL(string: Current.jobPath)!,
                                                    includingPropertiesForKeys: nil,
                                                    options: [])
            
        } catch {
            appendLog ("contentsOfDirectory: error")
            return false
        }
        
        guard MYZip.zipFiles(filesToZip, jobId: Current.job.id) else {
            appendLog ("zipFiles: error")
            return false
        }
        
        do {
            try fm.removeItem(atPath: Current.jobPath)
            MYJob.shared.removeJobWithId(Current.job.id)
            MYResult.shared.removeResultWithId(Current.job.id)
        } catch {
            appendLog ("removeFiles: error")
            return false
        }
        return true
    }
    
    //MARK:-
    
    private func startUpload() {
        User.shared.getUserToken(completion: { (redirect_url) in
            self.startUploadIncarico()
        }) {
            (errorCode, message) in
            self.appendLog("getToken: \(errorCode), \(message)")
            self.errore()
        }
    }
    
    private func startUploadIncarico() {
        let file = Config.Path.zip + jobId + "." + Config.File.zip
        let zipUrl = URL(fileURLWithPath: file)
        
        do {
            let data = try Data(contentsOf: zipUrl)
            appendLog("Creato: \(zipUrl)")
            uploadZip(zipUrl, data: data)
        }
        catch {
            appendLog("startUploadIncarico: error")
            self.errore()
        }
    }
    
    private func uploadZip (_ zipUrl: URL, data: Data) {
        appendLog("Start upload job: \(jobId)" )
        
        let url = URL(string: Config.Url.put)!
        let headers = [
            "Authorization" : User.shared.token
        ]
        let request: URLRequest!
        do {
            let req = try URLRequest(url: url, method: .post, headers: headers)
            request = req
        }
        catch {
            appendLog("Errore Auth: \(zipUrl)" )
            self.errore()
            return
        }
                
        Alamofire.upload(multipartFormData: {
            (formData) in
            formData.append(data,
                            withName: "object_file",
                            fileName:  url.absoluteString,
                            mimeType: "multipart/form-data")
            
            let json = [
                "object"        : "job",
                "object_id"     : self.jobId,
            ]
            
            for (key, value) in json {
                formData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, with: request, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    (response) in
                    self.appendLog("Result job-\(self.jobId): \(String(describing: response.result.value))" )
                    if let JSON = response.result.value {
                        print("Upload: Response.JSON: \(JSON)")
                        if MYZip.removeZipFile(zipUrl) {
                            self.done()
                            return
                        }
                        self.appendLog("Errore su cancellazione zip: \(self.jobId)")
                    }
                    else {
                        self.appendLog("let JSON = response.result.value")
                    }
                    self.errore()
                }
            case .failure(let encodingError):
                self.appendLog("Errore upluad: \(encodingError.localizedDescription)")
                self.errore()
            }
        })
    }
    
    private func done () {
        mainVC.alert("Incarico \(jobId)", message: "Inviato con successo")
        terminate()
    }
    private func errore () {
        mainVC.alert("Errore incarico \(jobId)", message: textLog)
        terminate()
    }
    
    private func terminate () {
        wheel.stop()
        mainVC.navigationController?.popToRootViewController(animated: true)
    }
}

