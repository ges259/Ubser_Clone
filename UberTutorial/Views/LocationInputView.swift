//
//  LocationInputView.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import UIKit

final class LocationInputView: UIView {
    
    
    // MARK: - Properties
    weak var delegate: LocationInputViewDelegate?
    
    
    
    var user: User? {
        didSet {
            titleLabel.text = user?.fullName
        }
    }
    
    
    
    // MARK: - Button
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    // MARK: - Label
    private let titleLabel: UILabel = {
        return UILabel().label(labelText: "GES",
                               LabelTextColor: UIColor.darkGray,
                               fontName: .system,
                               fontSize: 16)
    }()
    
    // MARK: - View
    private let startLocationIndicatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: .lightGray)
    }()
    
    private let linkingView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: .darkGray)
    }()
    
    private let destinationIndicatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: .black)
    }()
    
    
    
    // MARK: - TextField
    private lazy var startingLocationTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Current Location",
                                       backgroundColor: .systemGray6,
                                       textColor: .black,
                                       fontSize: 14,
                                       keyboardType: .webSearch,
                                       paddingLeftView: true)
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let tf = UITextField().textField(withPlaceholder: "Enter a destination..",
                                         backgroundColor: .systemGray4,
                                         textColor: .black,
                                         fontSize: 14,
                                         keyboardType: .webSearch,
                                         paddingLeftView: true)
        
        tf.delegate = self
        
        return tf
    }()
    
    
    
    
    
    
    // MARK: - Selectors
    @objc private func handleBackTapped() {
        self.delegate?.dismissLocationInputView()
    }
    
    
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        // setting shadow
        self.addShadow()
        
        self.addSubview(self.backButton)
        self.backButton.anchor(top: self.safeAreaLayoutGuide.topAnchor,
                               leading: self.leadingAnchor,
                               paddingTop: 0,
                               paddingLeading: 12,
                               width: 30,
                               height: 30)
        
        self.addSubview(self.titleLabel)
        self.titleLabel.anchor(centerX: self, centerY: self.backButton)
        

        self.addSubview(self.startingLocationTextField)
        self.startingLocationTextField.anchor(top: self.backButton.bottomAnchor,
                                              leading: self.leadingAnchor,
                                              trailing: self.trailingAnchor,
                                              paddingTop: 4,
                                              paddingLeading: 40,
                                              paddingTrailing: 40,
                                              height: 30)
        
        self.addSubview(self.destinationLocationTextField)
        self.destinationLocationTextField.anchor(top: self.startingLocationTextField.bottomAnchor,
                                                 leading: self.leadingAnchor,
                                                 trailing: self.trailingAnchor,
                                                 paddingTop: 12,
                                                 paddingLeading: 40,
                                                 paddingTrailing: 40,
                                                 height: 30)
        
        self.addSubview(self.startLocationIndicatorView)
        self.startLocationIndicatorView.clipsToBounds = true
        self.startLocationIndicatorView.layer.cornerRadius = 6 / 2
        self.startLocationIndicatorView.anchor(leading: self.leadingAnchor,
                                               paddingLeading: 20,
                                               width: 6,
                                               height: 6,
                                               centerY: self.startingLocationTextField)
        
        self.addSubview(self.destinationIndicatorView)
        self.destinationIndicatorView.anchor(leading: self.leadingAnchor,
                                             paddingLeading: 20,
                                             width: 6,
                                             height: 6,
                                             centerY: self.destinationLocationTextField)
        
        self.addSubview(self.linkingView)
        self.linkingView.anchor(top: self.startLocationIndicatorView.bottomAnchor,
                                bottom: self.destinationIndicatorView.topAnchor,
                                paddingTop: 4,
                                paddingBottom: 4,
                                width: 0.5,
                                centerX: self.startLocationIndicatorView)
        
        
        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





// MARK: - UITextFieldDelegate
extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let query = textField.text else { return false }
        
        self.delegate?.executeSearch(query: query)
        
        return true
    }
    
    
    
}
