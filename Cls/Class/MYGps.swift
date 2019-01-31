//
//  MYGps.swift
//  MysteryClient
//
//  Created by Developer on 09/08/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import Foundation
import CoreLocation

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
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
    }
    public func start (_ response: @escaping (CLLocationCoordinate2D)->()) {
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
