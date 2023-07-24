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

protocol HomeControllerDelegate: AnyObject {
    func handleMenuToggle()
}

protocol MenuControllerDelegate: AnyObject {
    func didSelect(option: MenuOptions)
}

protocol AddLocationControllerDelegate: AnyObject {
    func updateLocation(locationString: String, type: LocationType)
}


protocol SettingsControllerDelegate: AnyObject {
    func updateUser(_ controller: settingController)
}
