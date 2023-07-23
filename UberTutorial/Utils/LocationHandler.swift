//
//  LocationHandler.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/20.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    
    var locationManager: CLLocationManager!
    var location : CLLocation?
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
