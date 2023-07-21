//
//  HomeController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/18.
//

import UIKit
import FirebaseAuth
import MapKit

private enum ActionButtonConfiguration {
    case ShowMenu
    case dismissActionView
    
    init() {
        self = .ShowMenu
    }
}



final class HomeController: UIViewController {
    // MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    
    // 싱글톤
    private let service = Service.shared
    
    // fullName
    private var user: User? {
        didSet {
            self.locationInputView.user = user
        }
    }
    
    
    // enum 초기화
    private var actionButtonConfig = ActionButtonConfiguration()
    
    private var route: MKRoute?
    
    // 검색 후 찾은 배열
    private var searchResults = [MKPlacemark]()
    
    
    
    // MARK: - Layout
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.backgroundColor = .clear
        
        btn.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    
    
    
    
    
    
    // MARK: - Selectors
    @objc private func actionButtonPressed() {
        switch actionButtonConfig {
        case .ShowMenu:
            print("DEBUG: Handle show menu..")
        case .dismissActionView:
            // 주석 및 polyline삭제
            self.removeAnnotationsAndOverlays()
            
            // 화면 축소
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)

            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .ShowMenu)
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Helper Functions
    private func configureUI() {
        // 맵뷰 생성
        self.configureMapView()
        self.configureRideActionView()
        
        self.view.addSubview(self.actionButton)
        self.actionButton.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                 leading: self.view.leadingAnchor,
                                 paddingTop: 0,
                                 paddingLeading: 12,
                                 width: 30,
                                 height: 30)
        
        // delegate설정
        self.inputActivationView.delegate = self
        
        self.view.addSubview(self.inputActivationView)
        self.inputActivationView.anchor(top: self.actionButton.bottomAnchor,
                                        paddingTop: 30,
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
    
    private func configureMapView() {
        self.view.addSubview(self.mapView)
        self.mapView.frame = self.view.frame
        // 현재 자신의 위치
        self.mapView.showsUserLocation = true
        // 위치를 직접 설정 가능
            // Features -> Location -> Custom Location
        self.mapView.userTrackingMode = .follow
        self.mapView.showsUserLocation = true
        
        self.mapView.delegate = self
        
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
                                      height: viewHeight.LocationTableHeight)
        
        
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            
            // 테이블뷰 보이게
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = viewHeight.LocationTableHeight
            }
        }
    }
    
    private func configureRideActionView() {
        self.view.addSubview(self.rideActionView)
        self.rideActionView.frame = CGRect(x: 0,
                                           y: self.view.frame.height,
                                           width: self.view.frame.width,
                                           height: viewHeight.RideActionViewHeight)
    }
    
    
    
    
    
    
    // table view setting
    private func configureTableView() {
        
        self.tableView.register(LocationInputCell.self, forCellReuseIdentifier: TableViewIdentifier.LocationTableViewIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // table footer view
            // 이거의 존재 이유는 뭐지?
//        self.tableView.tableFooterView = UIView()
        
        let height = view.frame.height - viewHeight.LocationTableHeight
        
        self.tableView.frame = CGRect(x: 0,
                                      y: self.view.frame.height,
                                      width: self.view.frame.width,
                                      height: height)
        self.view.addSubview(self.tableView)

    }
    
    
    
    func configure() {
        self.configureUI()
         
        self.fetchUserData()
        self.fetchDrivers()
    }
    
    private func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .ShowMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .ShowMenu
            
        case .dismissActionView:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    
    
    private func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    
    private func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil) {
        
        let yOrigin = shouldShow ? self.view.frame.height - viewHeight.RideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            // 300크기 만큼 밑에서 올라옴
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        
        
        if shouldShow {
            guard let destination = destination else { return }
            self.rideActionView.destination = destination
        }
    }
    
    
    
    // MARK: - API
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else {return }
        
        service.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    // observe에 의해서 driver의 위치가 바뀔 때마다 fechDrivers가 호출 됨
    private func fetchDrivers() {
        guard let location = self.locationManager?.location else { return }
        
        service.fetchDrivers(location: location) { driver in
            
            // coordinate == driver의 위치
            guard let coordinate = driver.location?.coordinate else { return }
            
            // 주석(annotation)을 만듦
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            // driver의 위치가 바뀌면 주석이 여러개가 만들어지는 것을 방지하기 위해 driverIsVisible을 설정
            var driverIsVisible: Bool {
                // 맵뷰 안에 주석이 있는지 확인.
                return self.mapView.annotations.contains(where: { (annotation) in
                    
                    // 맵뷰 안에 있는 주석을 옵셔널 바인딩
                    guard let driverAnno = annotation as? DriverAnnotation else { return false}
                    
                    // 맵뷰 안에 주석의 아이디와 - driver의 아이디가 같다면 ===>>> 이미 맵뷰 안에 주석이 있다는 뜻
                        // return true -> 아래의 !driverIsVisible을 건너띔
                    if driverAnno.uid == driver.uid {
                        // 함수를 호출 -> dynamic 변수가 바뀌며 위치가 바뀜
                        driverAnno.updateAnnotationPosition(withCoodinate: coordinate)
                        
                        return true
                    }
                    return false
                })
            }
            if !driverIsVisible {
                // 맨 처음에만 annotation추가.
                self.mapView.addAnnotation(annotation)
            }
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

            configure()
        }
        
    }
    
    
    // sign out
    private func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("DEBUG: Error signin out")
        }
    }
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI 포함
        self.checkIfUserIsLoggedIn()

        self.enableLoactionServices()
        
//        self.signOut()
        
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



// MARK: - MapView Helper Functions
private extension HomeController {
    
    private func searchBy(naturalLanguageQuery: String, completion: @escaping ([MKPlacemark]) -> Void) {
        
        var results = [MKPlacemark]()
        
        // MKLocalSearch ==> 나의 주변을 검색할 수 있게 해줌
        let request = MKLocalSearch.Request()
        
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        
        // 검색 시작
        search.start { response, error in
            guard let response = response else { return }
            
            response.mapItems.forEach { item in
                // results에 데이터 추가
                results.append(item.placemark)
            }
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem) {
        
        // 요청서를 만듦
        let request = MKDirections.Request()
        // 현재 위치
        request.source = MKMapItem.forCurrentLocation()
        // 도착지
        request.destination = destination
        // 자동으로 길 찾아주도록
        request.transportType = .automobile
        
        // 여기서 요청을 전달
        let directionRequest = MKDirections(request: request)
        
        directionRequest.calculate { response, error in
            guard let response = response else { return }
            // 가장 첫번째 경로를 얻음
            self.route = response.routes[0]
            
            guard let polyline = self.route?.polyline else { return }
            
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlays() {
        // 주석 삭제
        self.mapView.annotations.forEach { annotation in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        // polyline 삭제
        if mapView.overlays.count > 0 {
            self.mapView.removeOverlay(self.mapView.overlays[0])
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
        self.dismissLocationView { _ in
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
            }
        }
    }
    
    
    func executeSearch(query: String) {
        self.searchBy(naturalLanguageQuery: query) { results in
            // 검색 결과 배열에 넣기
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
}




// MARK: - TableView Setting
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "이전 검색 결과" : "검색 결과"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifier.LocationTableViewIdentifier, for: indexPath) as! LocationInputCell
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        
        return cell
    }
     
    // delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // address 불러오기
        let selectedPlacemark = searchResults[indexPath.row]
        
        // 버튼 바꾸기
        self.configureActionButton(config: .dismissActionView)
        
        // 도착지를 맵 아이템으로 만들기
        let destination = MKMapItem(placemark: selectedPlacemark)
        
        // polyline(경로에 선) 만들기
            // 지도에 코드를 작성해야 보임
        self.generatePolyline(toDestination: destination)
        
        self.dismissLocationView { completion in
            // 새로운 도착지 주석 만들기
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            
            // 주석의 크기를 키우고 애니메이션을 추가
            self.mapView.selectAnnotation(annotation, animated: true)
            
            
            
            
            // #0 은 해당 배열의 각 주석을 나타냄
            // isKind(of: _ )는 특정 객체가 어떤 종류의 요소인지 같은 종류의 클래스를 감지한다.
                // 즉 driverAnnotation 주석을 걸러준다.
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            
            // 주석 배열을 생성
//            self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.zoomToFit(annotations: annotations)
            
            // 뷰 생성
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark)
        }
    }
}


// MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            
            let view = MKAnnotationView(annotation: annotation,
                                        reuseIdentifier: AnnotationIdentifier.annotationIdentifer)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueColor
            lineRenderer.lineWidth = 5
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}
