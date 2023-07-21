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
        return UILabel().label(labelText: "Test23411fdsafs",
                               LabelTextColor: .lightGray,
                               fontName: .system,
                               fontSize: 16)
    }()
    private let xLabel: UILabel = {
        return UILabel().label(labelText: "X",
                               LabelTextColor: .white,
                               fontName: .system,
                               fontSize: 30)
    }()
    private let uberXLabel: UILabel = {
        return UILabel().label(labelText: "Uber X",
                               LabelTextColor: .black,
                               fontName: .system,
                               fontSize: 18)
    }()
    private let infoView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .black
        view.clipsToBounds = true
        view.layer.cornerRadius = 60 / 2
        
        return view
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
        print("DEBUG: ActionButtonPressed")
    }
    
    
    
    
    
    
    
    
    
    // MARK: - Helper Function
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
        self.infoView.addSubview(self.xLabel)
        self.xLabel.anchor(centerX: self.infoView,
                           centerY: self.infoView)
        
        // uberXLabel autoLayout
        self.addSubview(self.uberXLabel)
        self.uberXLabel.anchor(top: self.infoView.bottomAnchor,
                               paddingTop: 8,
                               centerX: self)
        
        // separatorView autoLayout
        self.addSubview(self.separatorView)
        self.separatorView.anchor(top: self.uberXLabel.bottomAnchor,
                                  leading: self.leadingAnchor,
                                  trailing: self.trailingAnchor,
                                  paddingTop: 4,
                                  height: 0.75)
        
        // actionButton autoLayout
        self.addSubview(self.actionButton)
        self.actionButton.anchor(bottom: self.safeAreaLayoutGuide.bottomAnchor,
                                 leading: self.leadingAnchor,
                                 trailing: self.trailingAnchor,
                                 paddingBottom: 17,
                                 paddingLeading: 12,
                                 paddingTrailing: 12,
                                 height: 50)
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
}
