//
//  User.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import CoreLocation


enum AcccountType: Int {
    case passenger
    case driver
}


struct User {
    let uid: String
    let fullName: String
    let email: String
    var accountType: AcccountType!
    var location: CLLocation?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AcccountType(rawValue: index)
        }
    }
}



