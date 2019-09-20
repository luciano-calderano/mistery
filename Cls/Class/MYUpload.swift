//
//  MYHttp.swift
//  MysteryClient
//
//  Created by mac on 17/08/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import Alamofire
import UserNotifications

class MYUpload {
    static var textLog = ""

    class func appendLog (_ txt: String) {
        textLog += Date().toString(withFormat: Config.DateFmt.DataOraJson) + " -> " + txt + "\n"
    }
    
    class func startUpload() {
        User.shared.getUserToken(completion: { (redirect_url) in
            start()
        }) {
            (errorCode, message) in
            print("startUpload: ", errorCode, message)
        }
    }
    
    class func start() {
        let me = MYUpload()
        textLog = ""
        appendLog("Start")
        
        do {
            let zipPath = URL(string: Config.Path.zip)!
            let zipFiles = try FileManager.default.contentsOfDirectory(at: zipPath,
                                                                       includingPropertiesForKeys: nil,
                                                                       options:[])
            appendLog("Path Zip: \(zipFiles)")
            for zipUrl in zipFiles {
                if zipUrl.pathExtension != Config.File.zip {
                    continue
                }
                let data = try Data(contentsOf: zipUrl, options: .mappedIfSafe)
                appendLog("Creato: \(zipUrl)")
                me.uploadZip(zipUrl, data: data)
            }
        }
        catch {
            bugsnag.sendException("startUpload: error")
        }
    }
    
    class func startUploadIncarico() {
        textLog = ""
        appendLog("Start")

        let file = String(Current.job.id) + "." + Config.File.zip
        let zipPath = URL(string: Config.Path.zip)!
        let zipUrl = zipPath.appendingPathComponent(file)
        
        do {
            let data = try Data(contentsOf: zipUrl, options: .mappedIfSafe)
            appendLog("Creato: \(zipUrl)")
            MYUpload().uploadZip(zipUrl, data: data)
        }
        catch {
            bugsnag.sendException("startUpload: error")
        }
    }

    
    func uploadZip (_ zipUrl: URL, data: Data) {
        let jobId = zipUrl.deletingPathExtension().lastPathComponent
        MYUpload.appendLog("Start upload job: \(jobId)" )
        
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
            bugsnag.sendException("start: URLRequest error")
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
                "object_id"     : jobId,
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
                    MYUpload.appendLog("Result job-\(jobId): \(String(describing: response.result.value))" )
                    if let JSON = response.result.value {
                        print("Upload: Response.JSON: \(JSON)")
                        if MYZip.removeZipFile(zipUrl) {
                            self.done(id: jobId)
                        }
                        else {
                            self.error(id: jobId, err: "Errore su cancellazione zip: \(jobId)")
                        }
                        return
                    }
                    self.error(id: jobId, err: "let JSON = response.result.value")
                }
            case .failure(let encodingError):
                self.error(id: jobId, err: encodingError.localizedDescription)
            }
        })
    }
    
    private func done(id: String) {
        MYUpload.appendLog("End job: \(id)")
        let content = UNMutableNotificationContent()
        content.title = "Invio avvenuto"
        content.subtitle = "Incarico n. " + id
        content.body = "La trasmisisone dell'incarico n. \(id) è avvenuta corretamente"
        endUpload(content: content)
    }
    
    private func error(id: String, err: String) {
        MYUpload.appendLog(err)
        let content = UNMutableNotificationContent()
        content.title = "Errore"
        content.subtitle = "Incarico n. " + id
        content.body = "La trasmisisone dell'incarico n. \(id) ha dato il seguente errore: \(err)"
        endUpload(content: content)
        sendLog()
    }
    
    private func endUpload (content: UNMutableNotificationContent) {
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "MysteryClientJobSent", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        MYUpload.appendLog("Notification: \(content)")
        bugsnag.sendError(MYUpload.textLog)
        sendLog()
    }

    private func sendLog () {
//        let file = NSTemporaryDirectory() + "log.txt"
//        var zipFile = ""
//        do {
//            try MYUpload.textLog.write(toFile: file, atomically: true, encoding: .utf8)
//            zipFile = MYZip.zipLogFile(file)
//        }
//        catch {
//            bugsnag.sendException("sendLog")
//        }
//        
//        if zipFile.isEmpty {
//            bugsnag.sendException("Errore zipfile.empty")
//            return
//        }
//        do {
//            let data = try Data(contentsOf: URL(fileURLWithPath: zipFile))
//            let json = [
//                "object"        : "log",
//                "object_id"     : User.shared.getUsername(),
//                "object_file"   : data,
//                ] as [String: Any]
//            let req = MYHttp(.get, param: json, hasHeader: true)
//            req.load(ok: {
//                (response) in
//                print(response)
//            }) {
//                (code, error) in
//                print(code, error)
//            }
//        }
//        catch {
//
//        }
     }
}

