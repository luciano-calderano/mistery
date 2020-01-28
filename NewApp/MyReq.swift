//
//  MyReq.swift
//  MysteryClient
//
//  Created by Developer on 24/01/2020.
//  Copyright © 2020 Mebius. All rights reserved.
//

import Foundation

class MYReq {
    enum MYReqType: String {
        case get  = "GET"
        case post = "POST"
    }
    var url: URL!
    var type = MYReqType.post
    var header = JsonDict()
    var params = JsonDict()
    
    struct Response {
        var success = false
        var errorCode = 0
        var errorDesc = ""
        var jsonDict = JsonDict()
    }
    
    init(_ urlString: String) {
        url = URL(string: urlString)
    }

    // MARK: - Start
    
    func start (_ completion: @escaping (Response) -> ()) {
        Loader.start()
        let arr: Array = params.compactMap( { (key, value) -> String in return "\(key)=\(value)" } )
        let jsonString = arr.joined(separator: "&")
        
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        switch type {
        case .get:
            let newUrl = url.absoluteString + "?" + jsonString
            request.url = URL(string: newUrl)
        case .post:
            request.httpBody = jsonString.data(using: .utf8)!
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                Loader.stop()
                var resp = Response()
                if error != nil {
                    resp.errorDesc = error?.localizedDescription ?? "Generic error"
                    completion (resp)
                }
                if data == nil {
                    resp.errorDesc = "Missing data"
                    completion (resp)
                    return
                }
                
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let json = responseJSON as? JsonDict {
                    resp.jsonDict = json
                    if let status = json["status"] as? String {
                        if status == "ok" {
                            resp.success = true
                            completion (resp)
                            return
                        }
                        resp.errorDesc = json["message"] as? String ?? "Generic error"
                        completion (resp)
                    }
                }
                resp.errorDesc = "Errore decodifica Json"
                completion (resp)
            }
        }
        task.resume()
    }
}
