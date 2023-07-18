//
//  HomeController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/18.
//

import UIKit
import FirebaseAuth
import MapKit

final class HomeController: UIViewController {
    // MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    
    
    
    
    // MARK: - Selectors
    
    
    
    
    
    
    
    
    // MARK: - Helper Functions
    func configureUI() {
        self.view.addSubview(self.mapView)
        
        self.mapView.frame = self.view.frame
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - API
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            
            
        } else {
            
            print("DEBUG: User is logged in")
        }
        self.configureUI()
    }
    
    
    // sign out
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signin out")
        }
    }
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = .red
        
        
        self.checkIfUserIsLoggedIn()

        self.enableLoactionServices()
        
        
    }
}



// MARK: - Location services
extension HomeController: CLLocationManagerDelegate {
    private func enableLoactionServices(){
        
        self.locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined..")
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("DEBUG: break")
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            self.locationManager.startUpdatingLocation()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            self.locationManager.requestAlwaysAuthorization()
        @unknown default:
            print("DEBUG: default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
