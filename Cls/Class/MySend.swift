//
//  SendJob.swift
//  MysteryClient
//
//  Created by Lc on 10/05/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

class MySend {
    func sendResult (fromVC ctrl: UIViewController) {
        if let error = start() {
            ctrl.alert ("Errore nell'invio dell'incarico", message: error, okBlock: nil)
            return
        }
        ctrl.alert (Lng("readyToSend"), message: "", okBlock: { (ready) in
            ctrl.navigationController!.popToRootViewController(animated: true)
        })
    }
    
    private func start() -> String? {
        let fm = FileManager.default
        var jsonData = Data()
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: MYResult.resultDict, options: .prettyPrinted)
        } catch {
            return "JSONSerialization: error"
        }

        do {
            try jsonData.write(to: URL(fileURLWithPath: Current.jobPath + Config.File.json))
        } catch {
            return "json.write: error"
        }
        
        var filesToZip = [URL]()
        do {
            filesToZip = try fm.contentsOfDirectory(at: URL(string: Current.jobPath)!,
                                                    includingPropertiesForKeys: nil,
                                                    options: [])
            
        } catch {
            return "contentsOfDirectory: error"
        }

        guard MYZip.zipFiles(filesToZip, jobId: Current.job.id) else {
            return "zipFiles: error"
        }

        do {
            try fm.removeItem(atPath: Current.jobPath)
            MYJob.shared.removeJobWithId(Current.job.id)
            MYResult.shared.removeResultWithId(Current.job.id)
        } catch {
            return "removeFiles: error"
        }
        return nil
    }
}
