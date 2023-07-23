//
//  Enum.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/22.
//

//import Foundation


// Extensions - UIButton
enum FontStyle {
    case system
    case bold
    case AvenirLight
}
// Trip
enum TripState: Int {
    case requested
    case accepted
    case driverArrived
    case inProgress
    case arrivedAtDestination
    case completed
}
// HomeController
enum ActionButtonConfiguration {
    case ShowMenu
    case dismissActionView
    
    init() {
        self = .ShowMenu
    }
}
enum AnnotationType: String {
    case pickup
    case destination
}
// RideActionView
enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInprogress
    case endTrip
    
    init() {
        self = RideActionViewConfiguration.requestRide
    }
}
enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide: return "CONFIRM UBERX"
        case .cancel: return "CANCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSWNGER"
        case .dropOff: return "DROP OFF PASSENGER"
        }
    }
    init() {
        self = ButtonAction.requestRide
    }
}


// User
enum AcccountType: Int {
    case passenger
    case driver
}
