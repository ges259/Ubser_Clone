//
//  Protocol.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//


protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

protocol LocationInputViewDelegate: AnyObject {
    func dismissLocationInputView()
    func executeSearch(query: String)
}

protocol RideActionViewDelegate: AnyObject {
    func uploadTrip()
    func cancelTrip()
    func pickupPassenger()
    func dropOffPassenger()
}

protocol PickupControllerDelegate: AnyObject {
    func didAcceptTrip(_ trip: Trip)
}


