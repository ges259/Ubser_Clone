//
//  DB_Constants.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import FirebaseDatabase


let DB_REF = Database.database().reference()

// user
let REF_USERS = DB_REF.child("users")

// driver
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")

// trip
let REF_TRIPS = DB_REF.child("trips")

struct DB_String {
    // signUp
    static let email: String = "email"
    static let fullName: String = "fullName"
    static let accountType: String = "accountType"
    
    // trip
    static let pickerCoordinates: String = "pickerCoordinates"
    static let destinationCoordinates: String = "destinationCoordinates"
    static let driverUid: String = "driverUid"
    static let state: String = "state"
    
    init() {}
}
