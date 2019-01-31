//
//  AppDelegate.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import LcLib
import UserNotifications

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        createWorkingPath()
        MYLang.setup(langListCodes: ["it"], langFileName: "Lang.txt")
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        needsUpdate()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func needsUpdate() {
        guard let infoDictionary = Bundle.main.infoDictionary else { return }
        let appID = infoDictionary["CFBundleIdentifier"] as! String
        guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any] else { return }
        guard let resultCount = lookup["resultCount"] as? Int, resultCount == 1 else { return }
        guard let results = lookup["results"] as? [[String:Any]], let result = results.first else { return }
        guard let appStoreVersion = result["version"] as? String else { return }
        
        let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String
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
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Più tardi", style: .default, handler: nil))
        
        let ctrl = window?.rootViewController
        ctrl?.present(alert, animated: true, completion: nil)
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        var s = ""
        if kerr == KERN_SUCCESS {
            s = "Memory in use (in MB): \(info.resident_size/1000000). Free \(ProcessInfo.processInfo.physicalMemory/1000000)"
        }
        else {
            s = "Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error")
        }
        print(s)
        
        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindow.Level.alert + 1
        let alert = UIAlertController(title: "Memory Warning", message: s, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "confirm", comment: ""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
            topWindow?.isHidden = true // if you want to hide the topwindow then use this
            topWindow = nil // if you want to remove the topwindow then use this
        }))
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func createWorkingPath () {
        let fm = FileManager.default  
        for path in [Config.Path.zip, Config.Path.result] {
            if fm.fileExists(atPath: path) {
                continue
            }
            do {
                try fm.createDirectory(atPath: path,
                                       withIntermediateDirectories: true,
                                       attributes: nil)
            } catch let error as NSError {
                print("Directory (result) error: \(error.debugDescription)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse, withCompletionHandler
        completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        return completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
        notification: UNNotification, withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        return completionHandler(UNNotificationPresentationOptions.alert)
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
