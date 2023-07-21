//
//  Service.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import FirebaseCore
//import FirebaseAuth
//import FirebaseDatabase
import GeoFire
import CoreLocation

struct Service {
    
    
    // MARK: - Properties
    // 싱글톤
    static let shared = Service()
//    init() {}
    
    
    
    
    // MARK: - API
    func fetchUserData(uid: String,completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            
            let user = User(uid: uid,dictionary: dictionary)
            
            // completion
            completion(user)
        }
    }
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)

        REF_DRIVER_LOCATIONS.observe(.value) { snapshot in
            
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { uid, location in
                
                self.fetchUserData(uid: uid) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    
    
}


/*
 observe(_ eventType: GFEventType, with block: @escaping GFQueryResultBlock) -> UInt
 */



struct passengerService {

}
