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
                    bugsnag.sendError("Exif foto selezionata", code: 0, info: dict)
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
            df.dateFormat = "yyyy:MM:dd"
            let dS = df.string(from: d)
            df.dateFormat =  "HH:mm:ss"
            let tS = df.string(from: d)
            return (dS, tS)
        }
        
        let utc = utcConvert(dat)
        let resizedImage = pickedImage.resize(Config.maxPicSize)!
        crea(img: resizedImage, coo: coordinate, time: utc.time, date: utc.date)
        close()
    }
    
    func crea(img: UIImage, coo: CLLocationCoordinate2D, time: String, date: String) {
        let jpeg = img.jpegData(compressionQuality: 0.7)!
        let src = CGImageSourceCreateWithData(jpeg as CFData, nil)!
        let uti = CGImageSourceGetType(src)!
        
        let file = destFile
        let cfPath = CFURLCreateWithFileSystemPath(nil, file as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let dest = CGImageDestinationCreateWithURL(cfPath!, uti, 1, nil)
        let metadata = addGps(coo: coo, time: time, date: date)
        
        CGImageDestinationAddImageFromSource(dest!, src, 0, metadata)
        if (CGImageDestinationFinalize(dest!)) {
            self.delegate?.kpiAtchselectPhotoValid(true)
        } else {
            self.delegate?.kpiAtchselectPhotoValid(false)
            print("Error saving image with metadata")
        }
    }
    
    func addGps (coo: CLLocationCoordinate2D, time: String, date: String) -> CFDictionary {
        
        let gpsMetadata = NSMutableDictionary()
        if coo.latitude != 0 && coo.longitude != 0 {
            let latitudeRef = coo.latitude < 0.0 ? "S" : "N"
            let longitudeRef = coo.longitude < 0.0 ? "W" : "E"
            
            gpsMetadata[(kCGImagePropertyGPSLatitude as String)] = abs(coo.latitude)
            gpsMetadata[(kCGImagePropertyGPSLongitude as String)] = abs(coo.longitude)
            gpsMetadata[(kCGImagePropertyGPSLatitudeRef as String)] = latitudeRef
            gpsMetadata[(kCGImagePropertyGPSLongitudeRef as String)] = longitudeRef
        }
        else {
            bugsnag.sendError("Coordinate foto non trovate")
        }
        
        gpsMetadata[(kCGImagePropertyGPSTimeStamp as String)] = time
        gpsMetadata[(kCGImagePropertyGPSDateStamp as String)] = date
        
        let exifMetadata = NSMutableDictionary()
        exifMetadata[(kCGImagePropertyExifUserComment as String)] = date + " " + time + "\nLat.\(coo.latitude), Lon.\(coo.longitude)"
        exifMetadata[(kCGImagePropertyExifDateTimeOriginal as String)] =  date + " " + time

        let meta: CFDictionary = [
            kCGImagePropertyGPSDictionary as String : gpsMetadata,
            kCGImagePropertyExifDictionary as String : exifMetadata
            ] as CFDictionary
        print(meta)
        return meta
    }
}
