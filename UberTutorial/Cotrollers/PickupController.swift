//
//  PickupController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/21.
//

import UIKit
import MapKit

final class PickupController: UIViewController {
    
    
    // MARK: - Properties
    private let mapView = MKMapView()
    // init <--- LifeCycle
    let trip: Trip
    
    weak var delegate: PickupControllerDelegate?
    
    
    
    
    // MARK: - Layout
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x"), for: .normal)
        btn.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        
        return btn
    }()
    
    private let acceptTripBUtton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.backgroundColor = .white
        btn.setTitle("ACCEPT TRIP", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        
        btn.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        
        return btn
    }()
    
    private let pickupLabel: UILabel = {
        return UILabel().label(labelText: "Would you like to pickup this passenger?",
                               LabelTextColor: .white,
                               fontName: .system,
                               fontSize: 16)
    }()
    
    
    
    
    
    // MARK: - Selectors
    @objc private func handleDismissal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc private func handleAcceptTrip() {
        Service.shared.acceptTrip(trip: self.trip) { error, ref in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    
    // MARK: - API
    
    
    
    
    
    
    
    
    
    
    // MARK: - Helper Functions
    private func configureMapView() {
        // 보여질 맵뷰의 범위 정하기
        let region = MKCoordinateRegion(center: self.trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
        
        // 주석 달기
//        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let anno = MKPointAnnotation()
        anno.coordinate = self.trip.pickupCoordinates
        mapView.addAnnotation(anno)
        
        // 주석의 크기를 키우고 애니메이션을 추가
        self.mapView.selectAnnotation(anno, animated: true)
        
    }
    
    
    
    
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI
        self.configureUI()
        
        // configure MapView
        self.configureMapView()
        
        
        
        
    }
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 상태바 가리기
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    // MARK: - Configure UI
    private func configureUI() {
        self.view.backgroundColor = .backgroundColor
        
        // cancelButton
        self.view.addSubview(self.cancelButton)
        self.cancelButton.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                 paddingTop: 0,
                                 leading: self.view.leadingAnchor,
                                 paddingLeading: 12,
                                 width: 30,
                                 height: 30)
        // mapView
        self.mapView.clipsToBounds = true
        self.mapView.layer.cornerRadius = 270 / 2
        self.view.addSubview(self.mapView)
        self.mapView.anchor(width: 270,
                            height: 270,
                            centerX: self.view,
                            centerY: self.view,
                            paddingCenterY: -150)
        
        // pickupLabel
        self.view.addSubview(self.pickupLabel)
        self.pickupLabel.anchor(top: self.mapView.bottomAnchor,
                                paddingTop: 16,
                                centerX: self.view)
        
        // acceptTripBUtton
        self.view.addSubview(self.acceptTripBUtton)
        self.acceptTripBUtton.anchor(top: self.pickupLabel.bottomAnchor,
                                     paddingTop: 16,
                                     leading: self.view.leadingAnchor,
                                     paddingLeading: 32,
                                     trailing: self.view.trailingAnchor,
                                     paddingTrailing: 32,
                                     height: 50)
        
        
    }
}
