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
    func kpiAtchselectPhotoValid(_ isValid: Bool)
}

class KpiAtch: NSObject {
    var mainVC: UIViewController
    var delegate: KpiAtchDelegate?
    private var destFile = ""
    private var currentCoordinateGps = MYGps.shared.lastPosition

    init(mainViewCtrl: UIViewController) {
        mainVC = mainViewCtrl
    }
    
    func showArchSelection (file: String = "") {
        destFile = file
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
        mainVC.present(picker, animated: true) { }
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
                
        let asset = (info[UIImagePickerController.InfoKey.phAsset] as? PHAsset)
        var locCoo = asset?.location?.coordinate ?? CLLocationCoordinate2D()
        var locDat = asset?.location?.timestamp ?? Date()

        func convertDate(_ d: String) -> Date? {
            let datetime = d.replacingOccurrences(of:" |\\:|\\-", with: "", options: [.regularExpression])
            return datetime.toDate(withFormat: "yyyyMMddHHmmss") ?? nil
        }
        
        func readImageData(url: URL) {
            if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
                if let dict = imageProperties as? [String: Any] {
                    bugsnag.sendMsg("Exif foto selezionata", info: dict)
                    if let exif = dict[(kCGImagePropertyExifDictionary as String)] as? [String: Any] {
                        if let date = exif[(kCGImagePropertyExifDateTimeOriginal as String)] as? String {
                            if let d = convertDate(date) {
                                locDat = d
                                return
                            }
                        }
                        if let date = exif[(kCGImagePropertyExifDateTimeDigitized as String)] as? String {
                            if let d = convertDate(date) {
                                locDat = d
                                return
                            }
                        }
                    }
                    if let iptc = dict[(kCGImagePropertyIPTCDictionary as String)] as? [String: Any] {
                        if
                            let date = iptc[(kCGImagePropertyIPTCDateCreated as String)] as? String,
                            let time = iptc[(kCGImagePropertyIPTCTimeCreated as String)] as? String {
                            if let d = convertDate((date + time)) {
                                locDat = d
                                return
                            }
                        }
                    }
                    if let gps = dict[(kCGImagePropertyGPSDictionary as String)] as? [String: Any] {
                        if let cooLat = gps[(kCGImagePropertyGPSLatitude as String)] as? Double {
                            locCoo.latitude = cooLat
                        }
                        if let cooLon = gps[(kCGImagePropertyGPSLongitude as String)] as? Double {
                            locCoo.longitude = cooLon
                        }
                        if
                            let date = gps[(kCGImagePropertyGPSDateStamp as String)] as? String,
                            let time = gps[(kCGImagePropertyGPSTimeStamp as String)] as? String {
                            if let d = convertDate((date + time)) {
                                locDat = d
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
            df.dateFormat = "yyyy:MM:dd"
            let dS = df.string(from: d)
            df.dateFormat =  "HH:mm:ss"
            let tS = df.string(from: d)
            return (dS, tS)
        }
        
        let utc = utcConvert(locDat)
        let resizedImage = pickedImage.resize(Config.maxPicSize)!
        crea(img: resizedImage, coo: locCoo, time: utc.time, date: utc.date)
        close()
    }
    
    private func crea(img: UIImage, coo: CLLocationCoordinate2D, time: String, date: String) {
        let jpeg = img.jpegData(compressionQuality: 0.7)!
        let src = CGImageSourceCreateWithData(jpeg as CFData, nil)!
        let uti = CGImageSourceGetType(src)!
        
        let cfPath = CFURLCreateWithFileSystemPath(nil, destFile as CFString, .cfurlposixPathStyle, false)
        let dest = CGImageDestinationCreateWithURL(cfPath!, uti, 1, nil)
        let metadata = addGps(coo: coo, time: time, date: date)
        print(metadata)

        CGImageDestinationAddImageFromSource(dest!, src, 0, metadata)
        if (CGImageDestinationFinalize(dest!)) {
            self.delegate?.kpiAtchselectPhotoValid(true)
        } else {
            self.delegate?.kpiAtchselectPhotoValid(false)
            print("Error saving image with metadata")
        }
    }
    
    private func addGps (coo: CLLocationCoordinate2D, time: String, date: String) -> CFDictionary {
        let gpsMetadata = NSMutableDictionary()
        if coo.latitude != 0 && coo.longitude != 0 {
            let latitudeRef = coo.latitude < 0.0 ? "S" : "N"
            let longitudeRef = coo.longitude < 0.0 ? "E" : "W"
            
            gpsMetadata[(kCGImagePropertyGPSLatitude as String)] = abs(coo.latitude)
            gpsMetadata[(kCGImagePropertyGPSLongitude as String)] = abs(coo.longitude)
            gpsMetadata[(kCGImagePropertyGPSLatitudeRef as String)] = latitudeRef
            gpsMetadata[(kCGImagePropertyGPSLongitudeRef as String)] = longitudeRef
        }
        else {
            bugsnag.sendMsg("Coordinate foto non trovate")
        }
        
        gpsMetadata[(kCGImagePropertyGPSTimeStamp as String)] = time
        gpsMetadata[(kCGImagePropertyGPSDateStamp as String)] = date
        
        let exifMetadata = NSMutableDictionary()
        exifMetadata[(kCGImagePropertyExifDateTimeOriginal as String)] =  date + " " + time
        exifMetadata[(kCGImagePropertyExifUserComment as String)] = date + " " + time + " | Lat.\(coo.latitude) | Lon.\(coo.longitude)"

        let metadata = NSMutableDictionary()
        metadata[kCGImagePropertyGPSDictionary as String] = gpsMetadata
        metadata[kCGImagePropertyExifDictionary as String] = exifMetadata
        return metadata
    }
}
