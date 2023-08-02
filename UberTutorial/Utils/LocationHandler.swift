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
    
    
    
    // 사용되지 않는다는데?
        // 한번 알아보기
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            self.locationManager.requestAlwaysAuthorization()
//        }
//    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
