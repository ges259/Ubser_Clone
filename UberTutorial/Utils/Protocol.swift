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
// ContainerController
protocol HomeControllerDelegate: AnyObject {
    func handleMenuToggle()
}
// ContainerController
protocol MenuControllerDelegate: AnyObject {
    func didSelect(option: MenuOptions)
}
// SettingController
protocol AddLocationControllerDelegate: AnyObject {
    func updateLocation(locationString: String, type: LocationType)
}


protocol SettingsControllerDelegate: AnyObject {
    func updateUser(_ controller: SettingController)
}

protocol LocationResultControllerDelegate: AnyObject {
    // , type: LocationType
    func searchResultLocation(locationString: String)
}



// SettingControllerConatiner
protocol AddLocationControllerDelegate2: AnyObject {
    func popToSetting()
}

protocol SettingContainerDelegate2: AnyObject {
    func didSelectedCell(type: LocationType)
}
