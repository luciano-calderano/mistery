//
//  KpiAtch.swift
//  MysteryClient
//
//  Created by Lc on 12/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit
import Photos

protocol KpiAtchDelegate {
    func kpiAtchSelectedImage(withData data: Data)
}

class KpiAtch: NSObject {
    var mainVC: UIViewController
    var delegate: KpiAtchDelegate?
    private var currentCoordinateGps = MYGps.shared.lastPosition

    init(mainViewCtrl: UIViewController) {
        mainVC = mainViewCtrl
    }
    
    func showArchSelection () {
        MYGps.shared.start { (coordinateGps) in
            self.currentCoordinateGps = coordinateGps
        }

        let alert = UIAlertController(title: Lng("uploadPic") as String,
                                      message: "" as String,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Lng("picFromCam"),
                                      style: .default,
                                      handler: { (action) in
                                        self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: Lng("picFromGal"),
                                      style: .default,
                                      handler: { (action) in
                                        self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: Lng("cancel"),
                                      style: .cancel,
                                      handler: { (action) in
        }))
        
        mainVC.present(alert, animated: true) { }
    }
    
    //MARK:- Image picker
    
    private func openGallary() {
        presentPicker(type: .photoLibrary)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable (.camera) else {
            let alert = UIAlertController(title: "Camera Not Found",
                                          message: "This device has no Camera",
                                          preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            mainVC.present(alert, animated: true, completion: nil)
            return
        }
        presentPicker(type: .camera)
    }
    
    private func presentPicker (type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = type
        picker.allowsEditing = false
        if type == .camera {
            picker.cameraCaptureMode = .photo
        }
        let wheel = MYWheel()
        wheel.start(mainVC.view)
        mainVC.present(picker, animated: true) {
            wheel.stop()
        }
    }
    
    private func close () {
        mainVC.dismiss(animated: true, completion: nil)
    }
}

//MARK:-

extension KpiAtch: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        close()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertDict(info)
        let imgKey = convertKey(UIImagePickerController.InfoKey.originalImage)
        let assetKey = convertKey(UIImagePickerController.InfoKey.phAsset)
        
        guard let pickedImage = info[imgKey] as? UIImage else {
            return
        }
        var dat = Date()
        if picker.sourceType != .camera, let asset = info[assetKey] as? PHAsset {
            dat = asset.creationDate ?? Date();
            currentCoordinateGps = asset.location?.coordinate ?? currentCoordinateGps
        }

        func utcConvert(_ d: Date) -> (date: String, time: String) {
            let df = DateFormatter()
            df.timeZone = TimeZone(abbreviation: "UTC")
            df.dateFormat = Config.DateFmt.DataJson
            let dS = df.string(from: d)
            df.dateFormat =  Config.DateFmt.Ora + ":ss"
            let tS = df.string(from: d)
            return (dS, tS)
        }
        let utc = utcConvert(dat)
        
        let resizedImage = pickedImage.resize(Config.maxPicSize)!
        let resizedData = NSMutableData(data: resizedImage.jpegData(compressionQuality: 0.7)!)
        let resizedSource = CGImageSourceCreateWithData(resizedData as CFData, nil)
        let resizedExif = CGImageSourceCopyPropertiesAtIndex(resizedSource!, 0, nil)! as NSDictionary
        
        let finalExif = NSMutableDictionary(dictionary: resizedExif)
        
        let gpsDict = [
            kCGImagePropertyGPSLatitude     : fabs(currentCoordinateGps.latitude),
            kCGImagePropertyGPSLongitude    : fabs(currentCoordinateGps.longitude),
            kCGImagePropertyGPSLatitudeRef  : currentCoordinateGps.latitude < 0.0 ? "S" : "N",
            kCGImagePropertyGPSLongitudeRef : currentCoordinateGps.longitude < 0.0 ? "W" : "E",
            kCGImagePropertyGPSTimeStamp    : utc.time,
            kCGImagePropertyGPSDateStamp    : utc.date,
            ] as [CFString : Any]
        finalExif.setValue(gpsDict, forKey: kCGImagePropertyGPSDictionary as String)
        
        let uti = CGImageSourceGetType(resizedSource!)
        let destination = CGImageDestinationCreateWithData(resizedData as CFMutableData, uti!, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, resizedSource!, 0, (finalExif as CFDictionary?))
        CGImageDestinationFinalize(destination)
        self.delegate?.kpiAtchSelectedImage(withData: resizedData as Data)
        close()
    }
}

fileprivate func convertDict(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
