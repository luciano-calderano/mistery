//
//  User.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class User: NSObject {
    static let shared = User()

    struct UserData: Codable {
        public var user = ""
        public var pass = ""
        public var saved = false
        public var lastLogin: Date?
    }
        
    private var userdata = UserData()
    private var userToken = ""
    private let keyPlist = "MysteryClient"

    var token: String {
        get {
            return userToken.isEmpty ? userToken : "Bearer " + userToken
        }
        set {
            userToken = newValue
            print ("\ntoken: " + userToken)
        }
    }
    
    override init() {
        super.init()
        if let data = UserDefaults.standard.value(forKey: keyPlist) as? Data {
            if let ud = try? PropertyListDecoder().decode(UserData.self, from: data) {
                userdata = ud
                return
            }
        }

        //TODO: Vecchia versione da eliminare
        let userKey = "userKey"
        let kUsr = "keyUser"
        let kPwd = "keyPass"
        if let user = UserDefaults.standard.dictionary(forKey: userKey) {
            let ud = user as! [String : String]
            userdata.user = ud[kUsr] ?? ""
            userdata.pass = ud[kPwd] ?? ""
            userdata.saved = userdata.user.isEmpty == false
            userdata.lastLogin = userdata.saved ? Date() : nil
        }
    }

    func logged () -> Bool {
        return userdata.lastLogin != nil
    }
    
    func credential () -> (user: String, pass: String) {
        return (userdata.user, userdata.pass)
    }
    
    func logout() {
        userdata.lastLogin = nil
        if userdata.saved == false {
            userdata.user = ""
            userdata.pass = ""
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(userdata), forKey: keyPlist)
    }
    
    func checkUser (saveCredential: Bool, userName: String, password: String,
                    completion: @escaping (String) -> () = { (redirect_url) in },
                    failure: @escaping (String, String) -> () = { (errorCode, message) in }) {
        userdata = UserData()
        saveUserData()

        userdata.user = userName
        userdata.pass = password
        if saveCredential {
            userdata.saved = true
            saveUserData()
        }

        getUserToken(completion: { (redirect_url) in
            self.userdata.lastLogin = Date()
            self.saveUserData()
            completion(redirect_url)
        }) {
            (errorCode, message) in
            failure(errorCode, message)
        }
    }
    
    private func saveUserData (){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(userdata), forKey: keyPlist)
    }
    
    func getUserToken(completion: @escaping (String) -> (), failure: @escaping (String, String) -> ()) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        
        let param = [
            "grant_type"    : "password",
            "client_id"     : "mystery_app",
            "client_secret" : "UPqwU7vHXGtHk6JyXrA5",
            "version"       : "i" + version,
            "username"      : userdata.user,
            "password"      : userdata.pass,
        ]

        let req = MYHttp(.grant, param: param, showWheel: false, hasHeader: false)
        req.load(ok: {
            (response) in
            self.token = response.string("token->access_token")
            completion(response.string("redirect_url"))
        }) {
            (code, error) in
            failure(code, error)
        }
    }
}
