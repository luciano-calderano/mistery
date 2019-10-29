//
//  MYGps.swift
//  MysteryClient
//
//  Created by Developer on 09/08/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit
import CoreLocation

class MYGps: NSObject {
    static var coordinate = CLLocationCoordinate2D()
    static let myGps = MYGps()
    private let locationManager = CLLocationManager()
    
    static func getLocation () {
        if myGps.locationManager.delegate == nil {
            myGps.locationManager.delegate = myGps
            myGps.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            myGps.locationManager.distanceFilter = 100
            myGps.locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            myGps.locationManager.requestLocation()
        }
    }
}

extension MYGps: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let pos = manager.location?.coordinate {
            MYGps.coordinate = pos
            print("New pos: \(pos)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location updates error \(error)")
    }
}
