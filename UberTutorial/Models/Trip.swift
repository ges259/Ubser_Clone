//
//  Trip.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/21.
//

import MapKit

struct Trip {
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    var passenerUid: String!
    var driverUid: String?
    
    var state: TripState!
    
    init(passenerUid: String, dictionary: [String: Any]) {
        self.passenerUid = passenerUid
        
        if let pickupCoordinates = dictionary[DB_String.pickerCoordinates] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates = dictionary[DB_String.destinationCoordinates] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = dictionary[DB_String.driverUid] as? String ?? ""
        
        if let state = dictionary[DB_String.state] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}
