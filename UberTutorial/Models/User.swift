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
    var accountType: AcccountType!
    var location: CLLocation?
    var homeLocation: String?
    var workLocation: String?
    
    var firstInitial: String { return String(fullName.prefix(1)) }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let home = dictionary["homeLocation"] as? String {
            self.homeLocation = home
        }
        
        if let work = dictionary["workLocation"] as? String {
            self.workLocation = work
        }
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AcccountType(rawValue: index)
        }
    }
}



