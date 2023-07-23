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
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    
    // enum 초기화
    private var actionButtonConfig = ActionButtonConfiguration()
    
    private var route: MKRoute?
    
    // 검색 후 찾은 배열
    private var searchResults = [MKPlacemark]()
    
    
    // 싱글톤
    private let service = Service.shared
    
    // fullName
    private var user: User? {
        didSet {
            self.locationInputView.user = user
            
            // 유저가 passenger인 경우
            if user?.accountType == .passenger {
                print("DEBUG: User id Passenger")
                // 주변 driver의 위치를 가져오기
                self.fetchDrivers()
                
                // 검색 Label을 띄움
                self.configureLocationInputActivationView()
                
                //
                self.observeCurrentTrip()
                
                
            // 유저가 driver인 경우
            } else {
                // passenger가 driver찾기 버튼을 누르면
                // 주변 driver에서 실행 됨
                self.observeTrips()
                
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            
            if user.accountType == .driver {
                
                guard let trip = trip else { return }
                
                let pickupController = PickupController(trip: trip)
                pickupController.delegate = self
                pickupController.modalPresentationStyle = .fullScreen
                
                self.present(pickupController, animated: true)
            } else {
                print("DEBUG: Show ride action view for accepted trip..")
            }
        }
    }
    
    
    
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
            print("DEBUG: USER ID IS \(user?.uid)")
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
    
    
    
    
    // MARK: - Configure UI
    func configure() {
        self.configureUI()
         
        self.fetchUserData()

    }
    
    private func configureUI() {
        // 맵뷰 생성
        self.configureMapView()
        self.configureRideActionView()
        
        self.view.addSubview(self.actionButton)
        self.actionButton.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                 paddingTop: 0,
                                 leading: self.view.leadingAnchor,
                                 paddingLeading: 12,
                                 width: 30,
                                 height: 30)
        // table view
        self.configureTableView()
    }
    private func configureLocationInputActivationView() {
        self.view.addSubview(self.inputActivationView)
        // delegate설정
        self.inputActivationView.delegate = self
        self.inputActivationView.alpha = 0
        self.inputActivationView.anchor(top: self.actionButton.bottomAnchor,
                                        paddingTop: 30,
                                        width: self.view.frame.width - 64,
                                        height: 50,
                                        centerX: self.view)
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    
    private func configureMapView() {
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        self.mapView.frame = self.view.frame
        // 현재 자신의 위치
        self.mapView.showsUserLocation = true
        // 위치를 직접 설정 가능
            // Features -> Location -> Custom Location
        self.mapView.userTrackingMode = .followWithHeading
        
    }
    
    // ActivationLabel을 누르면 실행 ( 테이블뷰가 나오는 뷰 )
    private func configureLocationInputView() {
        // delegate 설정
        self.locationInputView.delegate = self
        self.view.addSubview(self.locationInputView)
        self.locationInputView.anchor(top: self.view.topAnchor,
                                      leading: self.view.leadingAnchor,
                                      trailing: self.view.trailingAnchor,
                                      height: viewHeight.LocationTableHeight)
        self.locationInputView.alpha = 0
        
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
        self.rideActionView.delegate = self
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
    // 왼쪽 상단 버튼 구성
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
    
    
    
    
    
    
    
    
    
    // MARK: - Helper Functions
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
            self.configure()
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
    
    
    
    private func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    
    // 밑에서 화면이 나옴
        // config에 따라 모든 것이 바뀜
        // config == 현재 passenger 및 driver의 상태를 알려주는 열거형
    // passenger인 상태
        // 1. 테이블뷰에서 셀을 선택했을 때
            // destination을 통해 도착지가 RideActionView에 뜸
        // 2. passenger와 driver가 서로 Accept를 했을 때
            // user가 누구인지에 따라 레이블의 텍스트가 바뀜
            // driver의 이름이 나옴
    // driver인 상태
        // 1. passenger와 driver가 서로 Accept를 했을 때
            // user가 누구인지에 따라 레이블의 텍스트가 바뀜
            // passenger의 이름이 나옴
    private func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil) {
        // shouldShow
            // true -> 화면에 보이게
            // false -> 숨기기
        let yOrigin = shouldShow ? self.view.frame.height - viewHeight.RideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            // 300크기 만큼 밑에서 올라옴
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        //
//        self.rideActionView.removeFromSuperview()
        
        // shouldShow가 true 이면
        if shouldShow {
            guard let config = config else { return }
            
            if let destination = destination {
                self.rideActionView.destination = destination
            }
            if let user = user {
                self.rideActionView.user = user
            }
            self.rideActionView.config = config
        }
    }
    
    
    
    // MARK: - API
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.service.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    private func observeTrips() {
        self.service.observeTrips { trip in
            self.trip = trip
        }
    }
    
    // 사용자가 passenger인 경우
        // passenger에게 trip의 현재 상태를 알려주는 함수
    private func observeCurrentTrip() {
        self.service.observeCurrentTrip { trip in
            self.trip = trip
            
            if trip.state == .accepted {
                self.shouldPresentLoadingView(false)
                
                guard let driverUid = trip.driverUid else { return }
                
                self.service.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            }
        }
    }
    
    // observe에 의해서 driver의 위치가 바뀔 때마다 fechDrivers가 호출 됨
    private func fetchDrivers() {
        
        guard let location = self.locationManager?.location else { return }
        
        self.service.fetchDrivers(location: location) { driver in
            
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
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI 포함
        self.checkIfUserIsLoggedIn()

        self.enableLoactionServices()
        
//        self.signOut()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let trip = trip else { return }
    }
}



// MARK: - CLLocationManagerDelegate
extension HomeController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {


        print("DEBUG: Did start monitoring for region \(region)")
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {


        self.rideActionView.config = .pickupPassenger
    }
    
    
    
    
    private func enableLoactionServices(){
        // delegate 설정
        self.locationManager?.delegate = self
        
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
    // polyline 만들기
    private func generatePolyline(toDestination destination: MKMapItem) {
        
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
    
    // 주석 및 polyline삭제
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
    
    // 화면 축소 시 보여질 맵의 크기
    private func centerMapOnUserLocation() {
        guard let coordinate = self.locationManager?.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    
    // 미정 - 다시 생각해보기
    // 사용자각 passenger일때
    // passenger의 주변에 범위 생성
        // driver가 passenger의 범위 안에 있을 때 알려주는 함수
    func setCustomRegion(withCoordinates coordinates: CLLocationCoordinate2D) {
        
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: "pickup")
        self.locationManager?.startMonitoring(for: region)
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
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
        }
    }
}


// MARK: - MapViewDelegate
extension HomeController: MKMapViewDelegate {
    // driver의 위치 자동 업데이트
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else { return }
        // driver만 업데이트
        guard user.accountType == .driver else { return }
        guard let userLocation = userLocation.location else { return }
        self.service.updateDriverLocation(location: userLocation)
    }
    
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




// MARK: - RideActionViewDelegate

// 사용자가 passenger인 경우
extension HomeController: RideActionViewDelegate {
    
    func uploadTrip() {
        guard let pickerCoordinates = locationManager?.location?.coordinate else { return }
        
        // 로딩(버퍼링, 도착지를 선택하면 driver가 ok를 할 때까지 기다리는) 화면 구현
            // extension - UIViewController
        self.shouldPresentLoadingView(true, message: "Finding you a ride..")
        
        // 도착지 좌표
        guard let destinationCoordinates = self.rideActionView.destination?.coordinate else { return }
        
        // 유저(passenger)의 위치와 도착지의 위치를 DB에 넣는 과정
        service.uploadTrip(pickerCoordinates, destinationCoordinates) { error, ref in
            if let error = error {
                print("DEBUG: Frailed to upload trip with error \(error)")
            }
            // rideActionView를 숨김
                // rideActionView: 도착지를 확인하고 driver를 부르는 버튼
            UIView.animate(withDuration: 0.4) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
    
    
    // passenger와 driver가 서로 ok를 하고난 후
        // passenger가 cancelTrip버튼을 누른 상황 <<<<<----- 현재 상황
            // 이후 일어날 일 : DB에서 서로 ok한 데이터가 사라짐
            // + passenger의 화면이 dismiss
    func cancelTrip() {
        service.cancelTrip { error, ref in
            if let error = error {
                print("DEBUG: Error deleting trip \(error.localizedDescription)")
                return
            }
            // 화면 축소
            self.centerMapOnUserLocation()
            // RideActionView 내리기
            self.animateRideActionView(shouldShow: false)
            // 주석 및 polyline삭제
            self.removeAnnotationsAndOverlays()
            
            
            // 버튼 바꾸기 ( backButton -> ShoMenu )
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .ShowMenu
            
            self.inputActivationView.alpha = 1
        }
    }
}



// MARK: - PickupControllerDelegate

// 사용자가 driver인 경우
extension HomeController: PickupControllerDelegate {
    
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        
        
        // 주석 만들기
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        self.mapView.addAnnotation(anno)
        
        // 위치
        print("DEBUG: setCustomRegion \(#function)")
        self.setCustomRegion(withCoordinates: trip.pickupCoordinates)
        
        
        // 주석의 크기를 키움
        self.mapView.selectAnnotation(anno, animated: true)
        
        let placmark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placmark)
        self.generatePolyline(toDestination: mapItem)
        
        self.mapView.zoomToFit(annotations: self.mapView.annotations)
        
        // Observe
        // passenger가 cancel을 누르면 RideActionView를 내림 (2번)
        self.service.observeTripCancel(trip: trip) {
            // 1. 주석 및 polyline 삭제
            self.removeAnnotationsAndOverlays()
            // 2. RideActionView 화면에 안 보이게 내리기
            self.animateRideActionView(shouldShow: false)
            // 맵뷰를 축소
            self.centerMapOnUserLocation()
            // cancel됐다고 driver의 화면에 alert창 띄우기
            self.presentAlertController(withTitle: "Oops!",
                                        message: "The passenger has decided to cancel this ride. Press Ok to continue")
        }
        
        // ObserveSingleEvent
        // 화면 전환
            // RideActionView가 나옴
        self.dismiss(animated: true) {
            self.service.fetchUserData(uid: trip.passenerUid) { passenger in
                // RideActionView 보이게 하기
                    // extension -> UIViewController
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
        }
    }
}
