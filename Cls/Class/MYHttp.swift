//
//  MYHttp.swift
//  MysteryClient
//
//  Created by mac on 17/08/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

enum MYHttpType {
    case grant
    case get
}

import Foundation
import Alamofire

class MYHttp {
    static let printJson = true
    
    private var json = JsonDict()    
    private var type: HTTPMethod!
    private var apiUrl = ""
    private var header = true
    
    init(_ httpType: MYHttpType, param: JsonDict, hasHeader: Bool = true) {
        json = param
        header = hasHeader
        
        switch httpType {
        case .get:
            type = .get
            apiUrl = Config.Url.get
        case .grant:
            type = .post
            apiUrl = Config.Url.grant
        }
    }
    
    func load(ok: @escaping (JsonDict) -> (), KO: @escaping (String, String) -> ()) {
        printJson(json)
        var headers = [String: String]()
        if header == true {
            headers["Authorization"] = User.shared.token
            print ("Auth: " + User.shared.token)
        }
        
        Alamofire.request(apiUrl,
                          method: type,
                          parameters: json,
                          headers: headers).responseString { response in
                            let data = self.fixResponse(response)
                            if data.isValid {
                                ok (data.dict)
                            } else {
                                KO (data.dict.string("err"), data.dict.string("msg"))
                            }
        }
    }
    
    func loadAtch(url: String, ok: @escaping (Data) -> ()) {
        printJson(json)
        var headers = [String: String]()
        headers["Authorization"] = User.shared.token

        Alamofire.request(url,
                          method: type,
                          parameters: json,
                          headers: headers).responseString { response in
                            if response.result.isSuccess  {
                                ok(response.data!)
                            }
        }
    }
    
    private func fixResponse (_ response: DataResponse<String>) -> (isValid: Bool, dict: JsonDict) {
        let statusCode = response.response?.statusCode
        let array = apiUrl.components(separatedBy: "/")
        let object = json.string("object")
        let page = object.isEmpty ? (array.last ?? apiUrl) : object
        
        if response.result.isSuccess && statusCode == 200 {
            var dict = removeNullFromJsonString(response.result.value!)
            printJson(dict)
            
            let isValid = dict.string("status") == "ok"
            if isValid == false {
                dict = [ "err" : "Server error \(dict.string("code"))\n[ \(page) ]", "msg" : dict.string("message") ]
            }
            return (isValid, dict)
        }
        let errorMessage = response.error == nil ? "Server error" :  (response.error?.localizedDescription)!
        let dict = [ "err" : "Server error \(statusCode ?? 0)\n[ \(page) ]",  "msg" : errorMessage ]
        return (false, dict)
    }
    
    private func removeNullFromJsonString (_ text: String) -> JsonDict {
        if text.isEmpty {
            return [:]
        }
        let jsonString = text.replacingOccurrences(of: ":null", with: ":\"\"")
        if let data = jsonString.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! JsonDict
            } catch {
                bugsnag.sendException(error.localizedDescription)
            }
        }
        return [:]
    }
    
    // MARK: - private
    
    fileprivate func printJson (_ json: JsonDict) {
        if MYHttp.printJson {
            print("\n[ \(apiUrl) ]\n\(json)\n------------")
        }
    }
}
