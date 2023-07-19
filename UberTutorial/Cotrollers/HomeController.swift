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
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    // 싱글톤
    private let service = Service.shared
    
    // fullName
    private var user: User? {
        didSet {
            self.locationInputView.user = user
        }
    }
    
    
    
    
    
    
    
    
    // MARK: - Selectors
    
    
    
    
    
    
    
    
    // MARK: - Helper Functions
    private func configureUI() {
        configureMapView()
        
        // delegate설정
        self.inputActivationView.delegate = self
        
        self.view.addSubview(self.inputActivationView)
        self.inputActivationView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                        paddingTop: 32,
                                        width: self.view.frame.width - 64,
                                        height: 50,
                                        centerX: self.view)
        
        self.inputActivationView.alpha = 0
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
        // table view
        self.configureTableView()
    }
    
    func configureMapView() {
        self.view.addSubview(self.mapView)
        self.mapView.frame = self.view.frame
        // 현재 자신의 위치
        self.mapView.showsUserLocation = true
        // 위치를 직접 설정 가능
            // Features -> Location -> Custom Location
        self.mapView.userTrackingMode = .follow
        self.mapView.showsUserLocation = true
    }
    
    // ActivationLabel을 누르면 실행 ( 테이블뷰가 나오는 뷰 )
    private func configureLocationInputView() {
        // delegate 설정
        self.locationInputView.delegate = self
        self.locationInputView.alpha = 0
        self.view.addSubview(self.locationInputView)
        self.locationInputView.anchor(top: self.view.topAnchor,
                                      leading: self.view.leadingAnchor,
                                      trailing: self.view.trailingAnchor,
                                      height: TableViewIdentifier.LocationTableViewHeight)
        
        
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            
            // 테이블뷰 보이게
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = TableViewIdentifier.LocationTableViewHeight
            }
        }
    }
    
    
    // table view setting
    private func configureTableView() {
        
        self.tableView.register(LocationInputCell.self, forCellReuseIdentifier: TableViewIdentifier.LocationTableViewIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // table footer view
            // 이거의 존재 이유는 뭐지?
        self.tableView.tableFooterView = UIView()
        
        let height = view.frame.height - TableViewIdentifier.LocationTableViewHeight
        
        self.tableView.frame = CGRect(x: 0,
                                      y: self.view.frame.height,
                                      width: self.view.frame.width,
                                      height: height)
        self.view.addSubview(self.tableView)

    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - API
    private func fetchUserData() {
        service.fetchUserData { user in
            self.user = user
        }
    }
    
    
    
    
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User is not logged in")
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
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                return
            }
        } catch {
            print("DEBUG: Error signin out")
        }
    }
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = .red
        
        // configure UI 포함
        self.checkIfUserIsLoggedIn()
        
        self.enableLoactionServices()
        
        
        self.fetchUserData()
        
        
    }
}



// MARK: - Location services
extension HomeController: CLLocationManagerDelegate {
    private func enableLoactionServices(){
        
        guard let locationManager = self.locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not determined..")
            self.locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("DEBUG: break")
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            self.locationManager?.startUpdatingLocation()
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            self.locationManager?.requestAlwaysAuthorization()
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        @unknown default:
            print("DEBUG: default")
            break
        }
    }
}






// MARK: - LocationInputActivationViewDelegate
extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        // 기존의 inputActivationView를 안 보이도록 설정
        self.inputActivationView.alpha = 0
        
        self.configureLocationInputView()
    }
}




// MARK: - LocationInputViewDelegate
extension HomeController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}




// MARK: - TableView Setting
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "2" : "5"
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifier.LocationTableViewIdentifier, for: indexPath) as! LocationInputCell
        
        return cell
    }
     
    
    
    // delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}
