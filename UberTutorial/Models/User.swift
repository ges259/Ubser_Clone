//
//  User.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import CoreLocation

struct User {
    let uid: String
    let fullName: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
