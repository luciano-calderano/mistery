//
//  MYZip.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import ZIPFoundation

class MYZip {
    private class func getZipFilePath (id: Int) -> String {
        return Config.Path.zip + "\(id)." + Config.File.zip
    }

    class func zipExists (id: Int) -> Bool {
        let file = MYZip.getZipFilePath(id: id)
        return FileManager.default.fileExists(atPath: file)
    }

    class func removeZipFile (_ url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        }
        catch  {
            print("Adding entry to ZIP archive failed with error:\(error)")
        }
        return false
    }
    class func zipFiles (_ files: [URL], jobId: Int) -> Bool {
        let zipFile = URL(fileURLWithPath: MYZip.getZipFilePath(id: jobId))
        guard let archive = Archive(url: zipFile, accessMode: .create) else  {
            return false
        }
        for url in files {
            do {
                try archive.addEntry(with: url.lastPathComponent, relativeTo: url.deletingLastPathComponent())
            } catch {
                print("Adding entry to ZIP archive failed with error:\(error)")
                return false
            }
        }
        return true
    }
    class func zipLogFile (_ file: String) -> String {
        let urlFile = URL(fileURLWithPath: file)
        let zipUrl = URL(fileURLWithPath: file + ".zip")
        try? FileManager.default.removeItem(at: zipUrl)
        guard let archive = Archive(url: zipUrl, accessMode: .create) else {
            return ""
        }
        do {
            try archive.addEntry(with: urlFile.lastPathComponent, relativeTo: zipUrl.deletingLastPathComponent())
            return zipUrl.absoluteString
        } catch {
            print("Adding entry to ZIP archive failed with error:\(error)")
            return ""
        }
    }
}
