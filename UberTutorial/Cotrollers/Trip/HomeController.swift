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
    // mapview
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private var route: MKRoute?
    
    // controller
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    
    // enum 초기화
    private var actionButtonConfig = ActionButtonConfiguration()
    
    // 검색 후 찾은 배열
    private var searchResults = [MKPlacemark]()
    
    // home / work placemark
    private var savedLocations = [MKPlacemark]()
    
    // Service - 싱글톤
    private let driverService = DriverService.shared
    private let passengerService = PassengerService.shared
    private let service = Service.shared
    
    // ContainerController - Delegate
    weak var delegate: HomeControllerDelegate?
    
    /*
     // user 바뀌는 경우
        // containerController에서 1번이 끝
     
     // driver didSet
        1. obsereTrips() 호출
            -> observeTrips로 인해
            -> observeTrips()가 실행
            -> service
            -> (driverServie)observeTrips
            -> DB에 trips에 사용자가 추가될 대마다 호출
     
     // passenger didSet
        1. driver의 위치를 업데이트
        2. LocationInputActivationView표시 ( where to? 창 )
        3. observeCurrentTrip() 표시 현재 상태(state)에 따라 다르게 행동
            -> rideActionView에 상태 전해주기 ( D - P 간 Trip중일 때 레이블, 버튼 등 이름 바꾸기)
        4. home / work 업데이트
     
     */
    var user: User? {
        didSet {
            self.locationInputView.user = user
            
            // 유저가 passenger인 경우
            if user?.accountType == .passenger {
                // 주변 driver의 위치를 가져오기
                self.fetchDrivers()
                // 검색 Label을 띄움
                self.configureLocationInputActivationView()
                // user가 바뀌면 상태(state)에 따라 다르게 행동
                    // alert창
                    // 레이블 / 버튼의 텍스트 바꾸기
                    // 완료 등
                // RideActionView에서 일어나는 일들은 다 user가 바뀌어 didSst을 통해 이루어짐
                self.observeCurrentTrip()
                // SettingController에서 설정한 home / work 위치데이터 저장
                self.configureSavedUserLocations()
                
            // 유저가 driver인 경우
            } else {
                // passenger가 driver찾기 버튼을 누르면
                // 주변 driver에서 실행 됨
                self.observeTrips()
            }
        }
    }
    /*
     // trip이 바뀌는 경우
        user가 바뀌면 -> observeTrips로 인해
        -> observeTrips()가 실행 -> service
        -> (driverServie)observeTrips
        -> DB에 trips에 사용자가 추가될 대마다 호출
     
     즉, passenger가 도착지를 정하고 버튼(CONFIRM UBERX)을 누르면
        -> trip이 바뀌며
        -> didSet실행 됨
     
        pickupContoller가 올라온다. ( 사용자를 받을것인지 확인하는 창 + 애니메이션 효과)
     */
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            
            // trip의 didSet (only driver인 경우)
            if user.accountType == .driver {
                guard let trip = trip else { return }
                
                // 사용자가 driver 일 때 -> Accept를 받는 뷰 ( +애니메이션 효과)
                let pickupController = PickupController(trip: trip)
                pickupController.delegate = self
                pickupController.modalPresentationStyle = .fullScreen
                
                self.present(pickupController, animated: true)
            }
        }
    }
    
    
    
    // MARK: - Layout
    // 뒤로가기 / 메뉴 버튼
    private lazy var actionButton: UIButton = {
        let btn = UIButton().button(title: nil, fontName: nil, fontSize: nil,
                                    backgroundColor: .clear,
                                    image: "baseline_menu_black_36dp")
        
        btn.addTarget(self, action: #selector(self.actionButtonPressed), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    // MARK: - Selectors
    // actionButtonConfig가 현재 무슨 상태인지에 따라() -----> 다른 역할을 수행 (showMenu or dismissActionView)
    
    // actionButtonConfig의 용도를 바꾸는 함수 => configureActionButton()
    @objc private func actionButtonPressed() {
        switch actionButtonConfig {
        // actionButtonConfig가 .showMenu일 때
        case .showMenu:
            // 메뉴가 나옴
                // 메뉴가 들어가는 방법은 containerController의 blackView 클릭 시 들어감
            self.delegate?.handleMenuToggle()
            
            
        // actionButtonConfig가 .dismikssActionView일 때
        case .dismissActionView:
            // 주석 및 polyline삭제
            self.removeAnnotationsAndOverlays()
            
            // 화면 축소
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                // LocationInputActivationView (Where to?)가 나오게 함
                self.inputActivationView.alpha = 1
                // 버튼의 이미지, 기능을 메뉴로 바꿈
                self.configureActionButton(config: .showMenu)
                // rideActionView를 들어가게 함
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    
        
    // MARK: - Configure UI
    // viewDidLoad()
    private func configureUI() {
        // 맵뷰 생성
        self.configureMapView()
        
        // LocationInputView(출발지 - 도착지) -> table view
        self.configureTableView()
        
        // configure - menu / back 버튼
        self.view.addSubview(self.actionButton)
        self.actionButton.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                 paddingTop: 12,
                                 leading: self.view.leadingAnchor,
                                 paddingLeading: 12,
                                 width: 34,
                                 height: 34)
        // rideActionView
        self.configureRideActionView()
    }
    
    // where to? 레이블
    private func configureLocationInputActivationView() {
        self.view.addSubview(self.inputActivationView)
        // delegate설정
        self.inputActivationView.delegate = self
        self.inputActivationView.alpha = 0
        self.inputActivationView.anchor(top: self.actionButton.bottomAnchor,
                                        paddingTop: 28,
                                        width: self.view.frame.width - (self.view.frame.width / 5),
                                        height: 50,
                                        centerX: self.view)
        // where to? 레이블 애니메이션 효과
        UIView.animate(withDuration: 1.5) {
            self.inputActivationView.alpha = 1
        }
    }
    
    // ActivationLabel ( where to?)을 누르면 뷰가 나옴 ( headerView + 테이블 뷰 )
    // 도착지 정하는 뷰 ( + 테이블뷰 )
    private func configureLocationInputView() {
        // delegate 설정
        self.locationInputView.delegate = self
        self.locationInputView.alpha = 0
        self.view.addSubview(self.locationInputView)
        self.locationInputView.anchor(top: self.view.topAnchor,
                                      leading: self.view.leadingAnchor,
                                      trailing: self.view.trailingAnchor,
                                      height: viewHeight.LocationTableHeight)
        // headerView  화면에 띄우기
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            
            // 하단 테이블뷰 보이게
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = viewHeight.LocationTableHeight
            }
        }
    }
    
    // locationInputView ( 테이블뷰 )에서 도착지를 선택하면 보이는 뷰
        // 화면 표시
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
        // 테이블 뷰 숨기기
        let height = view.frame.height - viewHeight.LocationTableHeight
        self.tableView.frame = CGRect(x: 0,
                                      y: self.view.frame.height,
                                      width: self.view.frame.width,
                                      height: height)
        self.view.addSubview(self.tableView)

    }
    
    // mapview setting
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
    // settingController에서 데이터를 저장
    private func configureSavedUserLocations() {
        guard let user = self.user else { return }
        
        self.savedLocations.removeAll()
        
        if let homeLocation = user.homeLocation {
            self.geocodeAddressString(address: homeLocation)
        }
        
        if let workLocation = user.workLocation {
            self.geocodeAddressString(address: workLocation)
        }
    }
    // LocationInputCell(tableView)에 저장될 (home / work) 위치 데이터
    private func geocodeAddressString(address: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let clPlacemark = placemarks?.first else { return }
            
            let placemark = MKPlacemark(placemark: clPlacemark)
            
            self.savedLocations.append(placemark)
            
            self.tableView.reloadData()
        }
    }
    
    
    
    // MARK: - Helper Functions
    // 왼쪽 상단 버튼의 이미지 + 용도를 바꾸는 메서드
        // 바뀐 용도는 Selector - actionButtonPressed에서 실행됨
    private func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
            
            
        case .dismissActionView:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .dismissActionView
        }
    }
    
    // locationInputView 숨기는 메서드
    private func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            // locationIputView 화면에서 안 보이게
            self.locationInputView.alpha = 0
            // 테이블 뷰 숨기기
            self.tableView.frame.origin.y = self.view.frame.height
            // locationInputView를 슈퍼클래스에서 삭제
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    
    
    
    // driver와 passenger가 서로 trip할 때 이 함수를 통해서 rideActionView의 레이블 및 버튼의 텍스트를 바꿈
    
    // 밑에서 화면이 나옴
    // true 일 때
        // config에 따라 모든 것이 바뀜
        // config : 현재 사용자(passenger 및 driver)의 상태를 알려주는 열거형
    // false 일 때
        // rideActionView 내리기
    
    
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
    private func animateRideActionView(shouldShow: Bool,
                                       destination: MKPlacemark? = nil,
                                       config: RideActionViewConfiguration? = nil,
                                       user: User? = nil) {
        // shouldShow
            // true -> 화면 보이게
            // false -> 화면 숨기기
        let yOrigin = shouldShow ? self.view.frame.height - viewHeight.RideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            // 300크기 만큼 밑에서 올라옴 또는 숨김
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            if let destination = destination {
                self.rideActionView.destination = destination
            }
            if let user = user {
                self.rideActionView.user = user
            }
            
            // RideActionView -> configureEnumUI()
            guard let config = config else { return }
            self.rideActionView.config = config
        }
    }
    
    
    
    // MARK: - Share API


    
    
    // MARK: - Passenger API
    // passenger에게 trip의 현재 상태를 알려주는 함수
        // trip의 상태에 따라 -> 역할을 수행 (config를 바꿈)
        // -> passenger의 rideActionView의 레이블 / 버튼의 텍스트를 바꿈
    // 이 함수는 user의 didSet -> only 사용자가 passenger일 때 한 번 불리고
    // -> passengerService를 통해서 데이터를 받아 자동적으로 수행
    private func observeCurrentTrip() {
        
        self.passengerService.observeCurrentTrip { trip in
            self.trip = trip
            
            guard let state = trip.state else { return }
            guard let driverUid = trip.driverUid else { return }
            
            switch state {
            case .requested:
                break
                
            case .denied:
                self.shouldPresentLoadingView(false)
                self.presentAlertController(withTitle: "Oops",
                                            message: "It looks like we couldn't find you a driver. please try again..")
                self.passengerService.deleteTrip { error, ref in
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
                    self.removeAnnotationsAndOverlays()
                }
                
                
            case .accepted:
                // passenger의 로딩화면 끝내기
                self.shouldPresentLoadingView(false)
                // 주석 및 polyline없애기
                self.removeAnnotationsAndOverlays()
                
                // zoomForActiveTrip
                    // ~!~!~ fetchDriver에서 zoomForActive()를 하는데 여기서까지 할 필요가 있나?
                self.zoomForActiveTrip(withDriverUid: driverUid)
                
                // RideActionView 표시
                self.service.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true,
                                               config: .tripAccepted,
                                               user: driver)
                }
                
                
            case .driverArrived:
                self.rideActionView.config = .driverArrived
                
                
            case .inProgress:
                self.rideActionView.config = .tripInprogress
                
                
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
                
                
            case .completed:
                // DB에서 trip데이터 삭제
                self.passengerService.deleteTrip { error, ref in
                    // rideActionView내리기
                    self.animateRideActionView(shouldShow: false)
                    // 화면을 자기 중심으로 확대, 축소
                    self.centerMapOnUserLocation()
                    // 버튼 이미지 바꾸기
                    self.configureActionButton(config: .showMenu)
                    // inputActivationView (lalel - ) 화면에 보이게 하기
                    self.inputActivationView.alpha = 1
                    // 얼럿창 띄우기
                    self.presentAlertController(withTitle: "Trip Completed",
                                                message: "We hope you enjoyed your trip")
                }
            }
        }
    }
    
 
    
    // observe에 의해서 driver의 위치가 바뀔 때마다 fechDrivers가 호출 됨
    private func fetchDrivers() {
        
        guard let location = self.locationManager?.location else { return }
        
        // driver <=== driver의 위치 정보가 담겨 있음
        self.passengerService.fetchDrivers(location: location) { driver in
            
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
                    // driver의 주석만 표시
                        // 맵뷰 안에 주석의 아이디와 - driver의 아이디가 같다면 ===>>> 이미 맵뷰 안에 주석이 있다는 뜻
                        // return true -> 아래의 !driverIsVisible을 건너띔
                    if driverAnno.uid == driver.uid {
                        // 함수를 호출 -> dynamic 변수가 바뀌며 위치가 바뀜
                        driverAnno.updateAnnotationPosition(withCoodinate: coordinate)
                        // zoomForActiveTrip
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
                        
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
    
    
    
    // MARK: - Drivers API
    // passenger가 CONFIRM UBERX를 누르면 ( driver 호출 하면 )
        // -> observe를 통해 DB에 trip이 추가되는 것을 관찰하여 driver에게 전달 됨
    private func observeTrips() {
        self.driverService.observeTrips { trip in
            self.trip = trip
        }
    }
    
    // passenger가 cancel trip을 눌렀을 때
    private func observeCancelledTrip(trip: Trip) {
        // passenger가 cancel버튼을 눌렀을 때 실행됨
        self.driverService.observeTripCancelled(trip: trip) {
            // 주석 지우기
            self.removeAnnotationsAndOverlays()
            // RideActionViesw 지우기
            self.animateRideActionView(shouldShow: false)
            // 화면 축소
            self.centerMapOnUserLocation()
            // 얼럿창 띄우기
            self.presentAlertController(withTitle: "Oops!",
                                        message: "The passenger has decided to cancel this ride. Press Ok to continue")
        }
    }
    
    // driver가 passenger를 태우고 난 후 상황
        // driver -> passenger 주석 및 polyline을 지움
        // driver -> destination 주석 및 polyline을 생성
            // 도착지 주변 범위 생성 + 도착지 줌
    private func startTrip() {
        guard let trip = self.trip else { return }
        
        self.driverService.updateTripState(trip: trip, state: .inProgress) { error, ref in
            self.rideActionView.config = .tripInprogress
            // 사용자의 주석 및 polyline을 삭제한다.
                // 여기서 passenger에서 다 지우고, 다른 코드에서 driver의 주석 및 polyline을 따라감
            self.removeAnnotationsAndOverlays()
            
            // 주석 만들기 + 크기 키우기
            self.mapView.addAnnotationAndSelect(forPlacemark: trip.destinationCoordinates)
            
            // 도착지로 polyline 만들기
            let placmark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placmark)
            self.generatePolyline(toDestination: mapItem)
            
            // 도착지 주변 원형 범위 만들기
            self.setCustomRegion(withType: .destination,
                                 coordinates: trip.destinationCoordinates)
            // 현재 위치와 도착지 -> 줌
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
        }
    }
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableLoactionServices()
        
        // configure UI
        self.configureUI()
    }
}



// MARK: - CLLocationManagerDelegate
extension HomeController: CLLocationManagerDelegate {
    
    private func enableLoactionServices(){
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
    
    // 시뮬레이터에서 시뮬레이션을 할 때 - 도착지 정보를 확인하기 위한 필요한 함수
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // passenger의 region 모니터링이 시작됐다고 알려줌
        // 여행을 시작하자마자 해당 대상 위치에 대한 모니터링을 시작한다.
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring pick up region ----- 11111 \(region)")
            
        }
        // driver가 passenger를 -> pickup을 하면 목적지에 범위가 생김 -> (다른 코드) 범위에 들어가면 도착표시
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitoring destination region ----- 22222 \(region)")
        }
    }
    
    // 따로 설정한 원형 범위 안에 다른 사용자가 들어오면 실행되는 함수
        // 1. passenger의 region안에 driver가 들어오면 실행
        // 2. 도착지의 region안에 driver가 들어오면 실행
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = self.trip else { return }

        if region.identifier == AnnotationType.pickup.rawValue {
            // trip state 업데이트 -> driver + passenger 모두에게 영향
            self.driverService.updateTripState(trip: trip, state: .driverArrived) { error, ref in
                // 사용자가 driver인 경우
                self.rideActionView.config = .pickupPassenger
            }
        }
        if region.identifier == AnnotationType.destination.rawValue {
            // drop passenger를 하면 실행 됨
            print("DEBUG: Did start monitoring destination region ----- 33333 \(region)")
            self.driverService.updateTripState(trip: trip, state: .arrivedAtDestination) { error, ref in
                self.rideActionView.config = .endTrip
            }
        }
    }
}



// MARK: - MapView Helper Functions
private extension HomeController {
    // 검색 기능 사용
    private func searchBy(naturalLanguageQuery: String, completion: @escaping ([MKPlacemark]) -> Void) {
        // 검색 결과를 저장할 배열
        var results = [MKPlacemark]()
        // 요청서 만들기
            // MKLocalSearch ==> 나의 주변을 검색할 수 있게 해줌
        let request = MKLocalSearch.Request()
        
            request.region = self.mapView.region
            request.naturalLanguageQuery = naturalLanguageQuery
        // 요청서 넣기
        let search = MKLocalSearch(request: request)
        
        // 검색 시작
        search.start { response, error in
            guard let response = response else { return }
            
            response.mapItems.forEach { item in
                // results에 데이터 추가
                results.append(item.placemark)
            }
            // completion을 통해 반환
            completion(results)
        }
    }
    
    // polyLine 만드는 함수
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
    
    // 주석 및 polyline 삭제
    func removeAnnotationsAndOverlays() {
        // 주석 삭제
        self.mapView.annotations.forEach { annotation in
            if let anno = annotation as? MKPointAnnotation {
                self.mapView.removeAnnotation(anno)
            }
        }
        
        // polyline 삭제
        if self.mapView.overlays.count > 0 {
            self.mapView.removeOverlay(self.mapView.overlays[0])
        }
    }
    
    // 화면 축소
        // 화면 축소 (cancel 또는 complete 등 이후)
    private func centerMapOnUserLocation() {
        guard let coordinate = self.locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        self.mapView.setRegion(region, animated: true)
    }
    
    // 주변에 원형 범위 생성
        // passenger 주변 또는 도착지 주변
    private func setCustomRegion(withType type: AnnotationType,
                                 coordinates: CLLocationCoordinate2D) {
        // 범위 만들기
        let region = CLCircularRegion(center: coordinates,
                                      radius: 25,
                                      identifier: type.rawValue)
        // 모니터링 시작
        self.locationManager?.startMonitoring(for: region)
    }
    
    // 두 사용자(driver와 passenger)가 한 화면에 다 나올 수 있도록 -> 맵뷰를 확대, 축소를 해줌
    private func zoomForActiveTrip(withDriverUid uid: String) {
        // 주석 배열 만들기
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach { annotation in
            
            // driver의 위치 주석을 알아내기 -> 배열에 넣기
            if let anno = annotation as? DriverAnnotation {
                if anno.uid == uid {
                    annotations.append(anno)
                }
            }
            // passenger의 위치 주석을 알아내기 -> 배열에 넣기
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        self.mapView.zoomToFit(annotations: annotations)
    }
}


// MARK: - LocationInputActivationViewDelegate
// locationInputActivationView - delegate
extension HomeController: LocationInputActivationViewDelegate {
    
    func presentLocationInputView() {
        // 기존의 inputActivationView를 안 보이도록 설정
        self.inputActivationView.alpha = 0
        
        // 도착지 정하는 뷰 ( + 테이블뷰 )를 화면에 보이게 하기
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
    // only passenger
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Saved Locations" : "Results"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.savedLocations.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifier.LocationTableViewIdentifier, for: indexPath) as! LocationInputCell
        
        if indexPath.section == 0 {
            cell.placemark = savedLocations[indexPath.row]
        }
        
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
        // 테이블뷰에서 셀을 선택하면
            // -> 버튼 바꾸기 ( showMenu / dismiss-)
            //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 버튼 바꾸기 (뒤로가기 버튼)
        self.configureActionButton(config: .dismissActionView)
        
        // address 불러오기
        let selectedPlacemark = indexPath.section == 0 ? savedLocations[indexPath.row] : searchResults[indexPath.row]
        // 도착지를 맵 아이템으로 만들기 ( polyline을 만들기 위해 )
        let destination = MKMapItem(placemark: selectedPlacemark)
        // polyline(경로에 선) 만들기
            // 지도에 코드를 작성해야 보임
        self.generatePolyline(toDestination: destination)
        
        // locationInputView를 화면에서 안 보이게 설정 후
            // -> mapView에서 주석 및 polyline 설정
            // -> + 줌
            // -> RideActionView를 화면에 보이도록 표시
                // config 설정 - requestRide
        self.dismissLocationView { completion in
            // 주석 달기 + 주석 크기 키우기
            self.mapView.addAnnotationAndSelect(forPlacemark: selectedPlacemark.coordinate)
            // #0 은 해당 배열의 각 주석을 나타냄
            // isKind(of: _ )는 특정 객체가 어떤 종류의 요소인지 같은 종류의 클래스를 감지한다.
                // 즉 driverAnnotation 주석을 걸러준다.
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            // Zoom
            self.mapView.zoomToFit(annotations: annotations)
            // rideActionView 뷰 올라오게 하기
            self.animateRideActionView(shouldShow: true,
                                       destination: selectedPlacemark,
                                       config: .requestRide)
        }
    }
}



// MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    // 사용자가 driver인 경우
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else { return }
        
        // 1. 사용자가 driver인 경우에만 driver의 위치 업데이트
        // 2. 사용자의 위치가 바뀜 -> 여기서 user가 바뀜 -> user의 didSet -> 사용자가 passenger라면
            // -> fetchDrivers() -> zoomForActiveTrip -> 자동으로 카메라가 맞춰짐
//        guard user.accountType == .driver else { return }
        if user.accountType == .driver {
            guard let userLocation = userLocation.location else { return }
            // driver의 위치 업데이트
            self.driverService.updateDriverLoction(location: userLocation)
        }
    }
    
    
    // 주석 설정
        // driver의 위치를 나타내는 주석에 대한 설정
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // driver의 주석이면.
        if let annotation = annotation as? DriverAnnotation {
            
            let view = MKAnnotationView(annotation: annotation,
                                        reuseIdentifier: AnnotationIdentifier.annotationIdentifer)
                view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    
    // polyline 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
                lineRenderer.strokeColor = .mainBlueColor
                lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}




// MARK: - RideActionViewDelegate
extension HomeController: RideActionViewDelegate {
    // 사용자가 passenger인 경우
        // - 여기 원래 trip을 파라미터로 받음 -> 나중에 차이점 확인해보기
    func uploadTrip() {
        guard let pickerCoordinates = locationManager?.location?.coordinate else { return }
        
        // 로딩(버퍼링, 도착지를 선택하면 driver가 ok를 할 때까지 기다리는) 화면 구현
            // extension - UIViewController
        self.shouldPresentLoadingView(true, message: "Finding you a ride..")
        
        // 도착지 좌표
        guard let destinationCoordinates = self.rideActionView.destination?.coordinate else { return }
        
        // 유저(passenger)의 위치와 도착지의 위치를 DB에 넣는 과정
            // driver가 accept trip버튼을 누르면 이 데이터를 가져감
        passengerService.uploadTrip(pickerCoordinates, destinationCoordinates) { error, ref in
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
    
    // 사용자가 passenger인 경우
        // passenger가 cancel을 누르면 이 함수가 실행 됨
    func cancelTrip() {
        self.passengerService.deleteTrip { error, ref in
            
            if let error = error {
                print("DEBUG: Error \(error.localizedDescription)")
            }
            // 화면 축소
            self.centerMapOnUserLocation()
            // RideActionView 내리기
            self.animateRideActionView(shouldShow: false)
            // 주석 및 polyline 지우기
            self.removeAnnotationsAndOverlays()
            // 버튼 용도 바꾸기
            self.configureActionButton(config: .showMenu)
            
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }
    }
    
    
    
    
    // 사용자가 driver인 경우
    func pickupPassenger() {
        self.startTrip()
    }
    
    // 사용자가 driver인 경우
    func dropOffPassenger() {
        guard let trip = self.trip else { return }
        // driverService -> updateTripState
        // 만약 .completed 일 때 passenger의 observe 들을 모두 지움
        self.driverService.updateTripState(trip: trip, state: .completed) { error, ref in
            // 주석 및 polyline 지우기
            self.removeAnnotationsAndOverlays()
            // 사용자에 맞게 화면 확대 or 축소
            self.centerMapOnUserLocation()
            // driver의 rideActionView내리기
            self.animateRideActionView(shouldShow: false)
        }
    }
}



// MARK: - PickupControllerDelegate
extension HomeController: PickupControllerDelegate {
    // 사용자가 driver인 경우
    func didAcceptTrip(_ trip: Trip) {
        // trip 업데이트
            // Service -> updateTripState
        self.trip = trip
        
        // 주석 만들기 + 주석의 크기를 키움
        self.mapView.addAnnotationAndSelect(forPlacemark: trip.pickupCoordinates)

        // circular region
        // drivedArrived 이후
        self.setCustomRegion(withType: .pickup,
                             coordinates: trip.pickupCoordinates)
        
        // polyline 만들기
        let placmark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placmark)
        self.generatePolyline(toDestination: mapItem)
        
        self.mapView.zoomToFit(annotations: self.mapView.annotations)
        
        self.observeCancelledTrip(trip: trip)
        
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
