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
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
            cp.addSubview(self.mapView)
        
        self.mapView.anchor(width: 268,
                            height: 268,
                            centerX: cp,
                            centerY: cp,
                            paddingCenterY: 32)
        self.mapView.layer.cornerRadius = 268 / 2
        
        return cp
    }()
    
    
    
    // MARK: - Layout
    private lazy var cancelButton: UIButton = {
        let btn = UIButton().button(title: nil,
                                    fontName: nil,
                                    fontSize: nil,
                                    image: "baseline_clear_white_36pt_2x")
        
//        btn.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x"), for: .normal)
        btn.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var acceptTripBUtton: UIButton = {
        let btn = UIButton().button(title: "ACCEPT TRIP",
                                    titleColor: .black,
                                    fontName: .bold,
                                    fontSize: 20,
                                    backgroundColor: .white)
        
        btn.addTarget(self, action: #selector(self.handleAcceptTrip), for: .touchUpInside)
        
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
        DriverService.shared.acceptTrip(trip: self.trip) { error, ref in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    @objc private func animateProgress() {
        self.circularProgressView.animatePulsatingLayer()
        self.circularProgressView.setProgressWithAnimation(duration: 15, value: 0) { // 멈추는 곳(?)
//            DriverService.shared.updateTripState(trip: self.trip,
//                                                 state: .denied) { error, ref in
//                // 시간이 다되면 돌아가기
//                self.dismiss(animated: true, completion: nil)
//            }
        }
    }
    
    
    
    
    // MARK: - Helper Functions
    private func configureMapView() {
        // 보여질 맵뷰의 범위 정하기
        let region = MKCoordinateRegion(center: self.trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
        
        // 주석 달기 + 주석 크기 키우기
        self.mapView.addAnnotationAndSelect(forPlacemark: self.trip.pickupCoordinates)
    }
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI
        self.configureUI()
        
        // configure MapView
        self.configureMapView()
        
        // animate
        self.perform(#selector(self.animateProgress), with: nil, afterDelay: 0.5)
        
        
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

        // circularProgressView
        self.view.addSubview(self.circularProgressView)
        self.circularProgressView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                         paddingTop: 32,
                                         width: 360,
                                         height: 360,
                                         centerX: self.view)
        
        
        // pickupLabel
        self.view.addSubview(self.pickupLabel)
        self.pickupLabel.anchor(top: self.circularProgressView.bottomAnchor,
                                paddingTop: 32,
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
