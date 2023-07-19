//
//  User.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//


struct User {
    let fullName: String
    let email: String
    let accountType: Int
    
    init(dictionary: [String: Any]) {
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
