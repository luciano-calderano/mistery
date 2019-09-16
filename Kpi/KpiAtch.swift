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
        MYHud.show()
        mainVC.present(picker, animated: true) {
            MYHud.hide()
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
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        var dat = Date()
        let asset = (info[UIImagePickerController.InfoKey.phAsset] as? PHAsset)
        var coordinate = asset?.location?.coordinate ?? CLLocationCoordinate2D()
        func readImageData(url: URL) {
            if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
                if let dict = imageProperties as? [String: Any] {
                    print(dict)
                    if let iptc = dict["{IPTC}"] as? [String: Any] {
                        if
                            let date = iptc["DigitalCreationDate"] as? String,
                            let time = iptc["DigitalCreationTime"] as? String {
                            let datetime = date + time
                            dat = datetime.toDate(withFormat: "yyyyMMddHHmmss")!
                        }
                    }
                    if let exif = dict["{Exif}"] as? [String: Any] {
                        if let date = exif["DateTimeOriginal"] as? String {
                            dat = date.toDate(withFormat: "yyyy:MM:dd HH:mm.ss")!
                        }
                        if let date = exif["DateTimeDigitized"] as? String {
                            dat = date.toDate(withFormat: "yyyy:MM:dd HH:mm.ss")!
                        }
                    }
                    if let gps = dict["{GPS}"] as? [String: Any] {
                        if let cooLat = gps["Latitude"] as? Double {
                            coordinate.latitude = cooLat
                        }
                        if let cooLon = gps["Longitude"] as? Double {
                            coordinate.longitude = cooLon
                        }
                        if
                            let date = gps["DateStamp"] as? String,
                            let time = gps["TimeStamp"] as? String {
                            let datetime = (date + time).replacingOccurrences(of: ":- ", with: "", options: [.regularExpression])
                            if let d = datetime.toDate(withFormat: "yyyyMMddHHmmss") {
                                dat = d
                            }
                        }
                    }
                }
            }
        }
        
        if picker.sourceType != .camera {
            let picUrl = info[UIImagePickerController.InfoKey.imageURL] as! URL
            readImageData(url: picUrl)
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
        print(utc)
        print(coordinate.latitude)
        print(coordinate.longitude)
        
        let resizedImage = pickedImage.resize(Config.maxPicSize)!
        let resizedData = NSMutableData(data: resizedImage.jpegData(compressionQuality: 0.7)!)
        let resizedSource = CGImageSourceCreateWithData(resizedData as CFData, nil)
        let resizedExif = CGImageSourceCopyPropertiesAtIndex(resizedSource!, 0, nil)! as NSDictionary
        
        let finalExif = NSMutableDictionary(dictionary: resizedExif)
        
        var gpsDict = [
            kCGImagePropertyGPSTimeStamp    : utc.time,
            kCGImagePropertyGPSDateStamp    : utc.date,
            kCGImagePropertyExifDateTimeDigitized : utc,
            ] as [CFString : Any]
        if coordinate.latitude != 0.0 || coordinate.longitude != 0.0 {
            gpsDict[kCGImagePropertyGPSLatitude]     = fabs(coordinate.latitude)
            gpsDict[kCGImagePropertyGPSLongitude]    = fabs(coordinate.longitude)
            gpsDict[kCGImagePropertyGPSLatitudeRef]  = coordinate.latitude < 0.0 ? "S" : "N"
            gpsDict[kCGImagePropertyGPSLongitudeRef] = coordinate.longitude < 0.0 ? "W" : "E"
        }
        
        finalExif.setValue(gpsDict, forKey: kCGImagePropertyGPSDictionary as String)
        
        let uti = CGImageSourceGetType(resizedSource!)
        let destination = CGImageDestinationCreateWithData(resizedData as CFMutableData, uti!, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, resizedSource!, 0, (finalExif as CFDictionary?))
        CGImageDestinationFinalize(destination)
        self.delegate?.kpiAtchSelectedImage(withData: resizedData as Data)
        close()
    }
}
