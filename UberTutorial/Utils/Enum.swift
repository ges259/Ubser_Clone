//
//  Enum.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/22.
//

//import Foundation

// service
enum TripState: Int {
    case requested
    case accepted
    case inProgress
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


// RideActionView
enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
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



