//
//  Service.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import GeoFire
import CoreLocation

struct Service {
    
    
    // MARK: - Properties
    // 싱글톤
    static let shared = Service()
//    init() {}
    
    
    
    
    // MARK: - API
    func fetchUserData(completion: @escaping (User) -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(dictionary: dictionary)
            print("DEBUG: User email is \(user.email)")
            print("DEBUG: fullName email is \(user.fullName)")
            
            completion(user)
        }
    }
    
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofile = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        
    }
}
