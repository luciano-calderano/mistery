//
//  Config.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//
// git: mcappios@git.mebius.it:projects/mcappios - Pw: Mc4ppIos
// web: mysteryclient.mebius.it - User: utente_gen - Pw: novella18

import Foundation
import LcLib
import Bugsnag

struct bugsnag {
    static func setUser (id: Int) {
        Bugsnag.configuration()?.setUser(String(id),
                                         withName: User.shared.getUsername(),
                                         andEmail: "Incarico selezionato")
        
    }
    static func sendMsg (_ reason: String, info:[String: Any]? = nil) {
        print(reason, info ?? "")
        var msg = " -> " + reason
        if info != nil {
            if let theJSONData = try? JSONSerialization.data(withJSONObject: info!, options: .prettyPrinted),
                let theJSONText = String(data: theJSONData, encoding: String.Encoding.ascii) {
                msg += " - " + theJSONText
            }
        }
        Bugsnag.leaveBreadcrumb(withMessage: msg)
    }
//
//    static func sendError (_ reason: String, code: Int = 0, info:[String: Any]? = nil) {
//        print(reason, info ?? "")
//        let err = NSError(domain: reason, code: code, userInfo: info)
//        Bugsnag.notifyError(err)
//    }
    static func sendException (_ reason: String, info:[String: Any]? = nil) {
        print(reason, info ?? "")
        let exception = NSException(name:NSExceptionName(rawValue: "NamedException"),
                                    reason: reason,
                                    userInfo: info)
        Bugsnag.notify(exception)
    }
}

typealias JsonDict = Dictionary<String, Any>
func Lng(_ key: String) -> String {
    return MYLang.value(key)
}

struct Current {
    static var job = Job()
    static var jobPath = ""
    static var result = JobResult()
    static var resultFile = ""
}

struct Config {
    enum AppType {
        case MC, EA
    }

    struct Url {
        static let home  = AppConf.urlHome
        static let grant = Config.Url.home + "default/oauth/grant"
        static let get   = Config.Url.home + "default/rest/get"
        static let put   = Config.Url.home + "default/rest/put"
        static let maps  = "http://maps.apple.com/?"
    }

    struct File {
        static let json = "job.json"
        static let zip = "zip"
        static let plist = "plist"
        static let idPrefix = "id_"
        static let jobsPlist = Config.Path.docs + "userjobs." + plist
    }

    struct Path {
        static let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
        static let result = Config.Path.docs + "result/"
        static let zip = Config.Path.docs + "zip/"
    }

    struct DateFmt {
        static let Ora           = "HH:mm"
        static let DataJson      = "yyyy-MM-dd"
        static let DataOraJson   = "yyyy-MM-dd HH:mm:ss"
    }

    static let maxPicSize:CGFloat = 1200
}
