//
//  String_Constants.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import CoreFoundation

//import Foundation

struct TableViewIdentifier {
    static let LocationTableViewIdentifier: String = "LocationTableView"
    static let MenuTableViewIdentifier: String = "MenuCell"
    // AddLocationController
    static let justCell: String = "Cell"
    
    init() {}
}

struct viewHeight {
    static let LocationTableHeight: CGFloat = 200
    static let RideActionViewHeight: CGFloat = 300
    
    init() {}
}

struct AnnotationIdentifier {
    static let annotationIdentifer: String = "DriverAnnotation"
    
    init() {}
}
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


