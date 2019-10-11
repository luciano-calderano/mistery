//
//  MYGps.swift
//  MysteryClient
//
//  Created by Developer on 09/08/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit
import CoreLocation
/*
class LCGps: NSObject {
    static var coordinate = CLLocationCoordinate2D()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
//        _ = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { timer in
//            self.start()
//        })
//
//        let authorizationStatus = CLLocationManager.authorizationStatus()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
//        if authorizationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
//        }
    }
    
    private func start () {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}

extension LCGps: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            start()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let pos = manager.location?.coordinate {
            LCGps.coordinate = pos
            print("New pos: \(pos)")
//            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location updates error \(error)")
    }

}
 */

class MYGps: NSObject {
    static let shared = MYGps()
    var lastPosition: CLLocationCoordinate2D {
        get {
            return lastKnownPos
        }
    }

    private let locationManager = CLLocationManager()
    private var lastKnownPos = CLLocationCoordinate2D()
    private var closure: ((CLLocationCoordinate2D)->()) = { loc in }

    override init() {
        super.init()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
    }
    func start (_ response: @escaping (CLLocationCoordinate2D)->()) {
        closure = response
        locationManager.requestLocation()
    }
}

extension MYGps: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let pos = manager.location?.coordinate {
            lastKnownPos = pos
        }
        print(lastKnownPos)
        closure(lastKnownPos)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        closure(lastKnownPos)
        print("Location updates error \(error)")
    }
}

