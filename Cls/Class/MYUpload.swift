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
    class func startUpload() {
        let me = MYUpload()
        do {
            let zipPath = URL(string: Config.Path.zip)!
            let zipFiles = try FileManager.default.contentsOfDirectory(at: zipPath,
                                                                    includingPropertiesForKeys: nil,
                                                                    options:[])
            for zipUrl in zipFiles {
                if zipUrl.pathExtension != Config.File.zip {
                    continue
                }
                let data = try Data(contentsOf: zipUrl, options: .mappedIfSafe)
                me.uploadZip(zipUrl, data: data)
            }
        }
        catch {
            print("startUpload: error")
        }
    }
    
    private func uploadZip (_ zipUrl: URL, data: Data) {
        let jobId = zipUrl.deletingPathExtension().lastPathComponent
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
            self.error(id: jobId, err: "start: URLRequest error")
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
                    if let JSON = response.result.value {
                        print("Upload: Response.JSON: \(JSON)")
                        MYZip.removeZipFile(url)
                        self.done(id: jobId)
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
        let content = UNMutableNotificationContent()
        content.title = "Invio avvenuto"
        content.subtitle = "Incarico n. " + id
        content.body = "La trasmisisone dell'incarico n. \(id) è avvenuta corretamente"
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "MysteryClientJobSent", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func error(id: String, err: String) {
        let content = UNMutableNotificationContent()
        content.title = "Errore"
        content.subtitle = "Incarico n. " + id
        content.body = "La trasmisisone dell'incarico n. \(id) ha dato il eguente errore: \(err)"
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "MysteryClientJobSent", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        print("\nUpload error:\n", content)

    }
}

