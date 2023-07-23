//
//  RideActionView.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/21.
//

import UIKit
import MapKit




final class RideActionView: UIView {
    
    
    // MARK: - Properties
    
    var delegate: RideActionViewDelegate?
    
    // enum properties
    var buttonAction = ButtonAction()
    
    var config: RideActionViewConfiguration? {
        didSet {
            self.configureEnumUI(withConfig: self.config!)
        }
    }
    
    var user: User?
    
    
    var destination: MKPlacemark? {
        didSet {
            self.titleLabel.text = destination?.name
            self.addressLabel.text = destination?.address
        }
    }
    
    
    
    
    
    
    // MARK: - Label
    private let titleLabel: UILabel = {
        return UILabel().label(labelText: "Test Address Title",
                               fontName: .system,
                               fontSize: 18)
    }()
    private let addressLabel: UILabel = {
        return UILabel().label(LabelTextColor: .lightGray,
                               fontName: .system,
                               fontSize: 16)
    }()
    private let infoViewLabel: UILabel = {
        return UILabel().label(labelText: "X",
                               LabelTextColor: .white,
                               fontName: .system,
                               fontSize: 30)
    }()
    private let uberInfoLabel: UILabel = {
        return UILabel().label(labelText: "Uber X",
                               LabelTextColor: .black,
                               fontName: .system,
                               fontSize: 18)
    }()
    private let infoView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: .black,
                                            cornerRadius: 60 / 2)
    }()
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews: [self.titleLabel,
                                                          self.addressLabel],
                                       axis: .vertical,
                                       distribution: .fillEqually,
                                       spacing: 4,
                                       alignment: .center)
    }()
    
    

    
    
    // MARK: - View
    private let separatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: .lightGray)
    }()
    
    
    
    
    
    
    // MARK: - Button
    private lazy var actionButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.backgroundColor = .black
        btn.setTitle("CONFIRM UBERX", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    
    // MARK: - Selector
    @objc private func actionButtonPressed() {
        switch buttonAction {
        case .requestRide:
            self.delegate?.uploadTrip()
        case .cancel:
            self.delegate?.cancelTrip()
        case .getDirections:
            print("DEBUG: Handle directions..")
        case .pickup:
            print("DEBUG: Handle pickup..")
        case .dropOff:
            print("DEBUG: Handle dropOff..")
        }
    }
    
    
    
    
    
    
    
    
    
    // MARK: - Helper Function
    func configureEnumUI(withConfig config: RideActionViewConfiguration) {
        guard let user = user else { return }
        
        switch config {
        case .requestRide:
            self.buttonAction = .requestRide
            self.actionButton.setTitle(self.buttonAction.description, for: .normal)
            
            
        case .tripAccepted:
            // driver인 경우 -> passenger가 누군지 알려줌
            if user.accountType == .passenger {
                self.titleLabel.text = "En Route To Passenger2222"
                self.buttonAction = .getDirections
                self.actionButton.setTitle(self.buttonAction.description, for: .normal)
                // passenger인 경우 -> driver가 누군지 알려줌
            } else {
                self.titleLabel.text = "Driver En Route2222"
                self.addressLabel.text = nil
                self.buttonAction = .cancel
                self.actionButton.setTitle(self.buttonAction.description, for: .normal)
            }
            
            
        case .pickupPassenger:
            self.titleLabel.text = "Arrived At pasenger Location"
            self.buttonAction = .pickup
            self.actionButton.setTitle(self.buttonAction.description, for: .normal)
            
            
        case .tripInprogress:
            // ~ 인 경우
            if user.accountType == .driver {
                self.actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                self.actionButton.isEnabled = false
                
                // ~ 인 경우
            } else {
                self.buttonAction = .getDirections
                self.actionButton.setTitle(buttonAction.description, for: .normal)
            }
            self.titleLabel.text = "En Route To Destination"
            
            
        case .endTrip:
            if user .accountType == .driver {
                self.actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                self.actionButton.isEnabled = false
            } else {
                self.buttonAction = .dropOff
                self.actionButton.setTitle(buttonAction.description, for: .normal)
            }
        }
        
        
        self.infoViewLabel.text = String(user.fullName.first ?? "X")
        self.uberInfoLabel.text = user.fullName
    }
    
    
    
    
    
    
    // MARK: - LifeCyle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // view setup
        self.backgroundColor = .white
        self.addShadow()
        
        // configure UI
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Configure UI
    private func configureUI() {
        // stackView autoLayout
        self.addSubview(self.stackView)
        self.stackView.anchor(top: self.topAnchor,
                              paddingTop: 12,
                              centerX: self)
        
        // infoView autoLayout
        self.addSubview(self.infoView)
        self.infoView.anchor(top: self.stackView.bottomAnchor,
                             paddingTop: 16,
                             width: 60,
                             height: 60,
                             centerX: self)
        
        // xLabel autoLayout
        self.infoView.addSubview(self.infoViewLabel)
        self.infoViewLabel.anchor(centerX: self.infoView,
                           centerY: self.infoView)
        
        // uberXLabel autoLayout
        self.addSubview(self.uberInfoLabel)
        self.uberInfoLabel.anchor(top: self.infoView.bottomAnchor,
                               paddingTop: 8,
                               centerX: self)
        
        // separatorView autoLayout
        self.addSubview(self.separatorView)
        self.separatorView.anchor(top: self.uberInfoLabel.bottomAnchor,
                                  paddingTop: 4,
                                  leading: self.leadingAnchor,
                                  trailing: self.trailingAnchor,
                                  height: 0.75)
        
        // actionButton autoLayout
        self.addSubview(self.actionButton)
        self.actionButton.anchor(bottom: self.safeAreaLayoutGuide.bottomAnchor,
                                 paddingBottom: 17,
                                 leading: self.leadingAnchor,
                                 paddingLeading: 12,
                                 trailing: self.trailingAnchor,
                                 paddingTrailing: 12,
                                 height: 50)
    }
}





