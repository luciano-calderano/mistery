//
//  MainOnAppear.swift
//  MysteryClient
//
//  Created by Developer on 11/10/2019.
//  Copyright © 2019 Mebius. All rights reserved.
//

import UIKit

struct MainOnAppear {
    static func execute() {
        let main = MainOnAppear()
        MYUpload.startUpload()
        main.clearTmp()
        main.needsUpdate()
    }
    
    func clearTmp() {
        let tmp = NSTemporaryDirectory()
        let fm = FileManager.default
        for f in try! fm.contentsOfDirectory(atPath: tmp) {
            try? fm.removeItem(at: URL(fileURLWithPath: tmp + f))
        }
    }
    
    func needsUpdate() {
        guard let infoDictionary = Bundle.main.infoDictionary else { return }
        let appID = infoDictionary["CFBundleIdentifier"] as! String
        guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any] else { return }
        guard let resultCount = lookup["resultCount"] as? Int, resultCount == 1 else { return }
        guard let results = lookup["results"] as? [[String:Any]], let result = results.first else { return }
        guard let appStoreVersion = result["version"] as? String else { return }
        
        let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String ?? ""
        if (appStoreVersion != currentVersion) {
            showAlert()
        }
    }
    
    private func showAlert () {
        let alert = UIAlertController(title: "Aggiornamento Mystery Client",
                                      message: "E' presente una nuova versione su apple store.\nL'app deve essere aggiornata",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            let urlStr = "https://itunes.apple.com/it/app/mystery-client/id1380166821?mt=8"
            let url = URL(string: urlStr)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Più tardi", style: .default, handler: nil))
        let window = UIApplication.shared.windows.first
        let ctrl = window?.rootViewController
        ctrl?.present(alert, animated: true, completion: nil)
    }
}

