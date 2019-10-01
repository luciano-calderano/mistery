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
import Bugsnag

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        createWorkingPath()
        MYLang.setup(langListCodes: ["it"], langFileName: "Lang.txt")
        registerForPushNotifications()
        Bugsnag.start(withApiKey: AppConf.keyBugSnag)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        needsUpdate()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        receivedMemoryWarning()        
    }
}

extension AppDelegate {
    private func needsUpdate() {
        guard let infoDictionary = Bundle.main.infoDictionary else { return }
        let appID = infoDictionary["CFBundleIdentifier"] as! String
        guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any] else { return }
        guard let resultCount = lookup["resultCount"] as? Int, resultCount == 1 else { return }
        guard let results = lookup["results"] as? [[String:Any]], let result = results.first else { return }
        guard let appStoreVersion = result["version"] as? String else { return }
        
        let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String ?? ""
        if ("2." + appStoreVersion != currentVersion) {
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
        
        let ctrl = window?.rootViewController
        ctrl?.present(alert, animated: true, completion: nil)
    }
    
    private func receivedMemoryWarning() {
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
                bugsnag.sendException("Directory (result) error: \(error.debugDescription)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        startNotification()
    }
    private func startNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            [weak self] granted, error in
            guard let self = self else { return }
            print("Permission granted: \(granted)")
            guard granted else { return }
            
            self.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        User.shared.tokenPush = token
        bugsnag.sendMsg("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        bugsnag.sendMsg("Failed to register: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        
        bugsnag.sendMsg("Userinfo: didReceiveRemoteNotification", info: userInfo as? [String : Any])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        bugsnag.sendMsg("Userinfo: userNotificationCenter", info: userInfo as? [String : Any])
        completionHandler()
    }
}

