//
//  SendJob.swift
//  MysteryClient
//
//  Created by Lc on 10/05/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

class SendJob {
    class func send (dict: JsonDict) -> String? {
        let sendJob = SendJob()
        let result = sendJob.createZipFileWithDict(dict)
        return result
    }
//    class func send (dict: JsonDict) -> Bool {
//        let sendJob = SendJob()
//        let result = sendJob.createZipFileWithDict(dict)
//        if result.isEmpty {
//            return true
//        }
//        if let vc = UIApplication.shared.keyWindow!.rootViewController {
//            vc.alert ("Errore nell'invio dell'incarico", message: result, okBlock: nil)
//        }
//        return false
//    }

    
    func createZipFileWithDict (_ dict: JsonDict) -> String? {
        let fm = FileManager.default
        var jsonData = Data()
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
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
