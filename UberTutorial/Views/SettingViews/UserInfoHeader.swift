//
//  UserInfoHeader.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/25.
//

import UIKit

final class UserInfoHeader: UIView {
    
    
    // MARK: - Properties
    private var user: User
    
    
    
    
    
    
    
    // MARK: - Layout
    private lazy var profileView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: .darkGray)
    }()
    
    
    
    
    private lazy var initialLabel: UILabel = {
        return UILabel().label(labelText: self.user.firstInitial,
                               LabelTextColor: .white,
                               fontName: .system,
                               fontSize: 42)
    }()
    private lazy var fullNameLabel: UILabel = {
        return UILabel().label(labelText: self.user.fullName,
                               fontName: .system,
                               fontSize: 16)
    }()
    private lazy var emailLabel: UILabel = {
        return UILabel().label(labelText: self.user.email,
                               fontName: .system,
                               fontSize: 14)
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews: [self.fullNameLabel,
                                                          self.emailLabel],
                                       axis: .vertical,
                                       distribution: .fillEqually,
                                       spacing: 4)
    }()
    
    
    
    
    // MARK: - LifeCycle
    init(user: User, frame: CGRect) {
        self.user = user
        
        super.init(frame: frame)
        
        self.configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Configure UI
    private func configureUI() {
        self.backgroundColor = UIColor.white
        
        // profileView
        self.addSubview(self.profileView)
        self.profileView.clipsToBounds = true
        self.profileView.layer.cornerRadius = 64 / 2
        self.profileView.anchor(leading: self.leadingAnchor,
                                     paddingLeading: 12,
                                     width: 64,
                                     height: 64,
                                     centerY: self)
        
        // initialLabel
        self.profileView.addSubview(self.initialLabel)
        self.initialLabel.anchor(centerX: self.profileView,
                                 centerY: self.profileView)
        
        
        // stackView
        self.addSubview(self.stackView)
        self.stackView.anchor(leading: self.profileView.trailingAnchor,
                              paddingLeading: 12,
                              centerY: self.profileView)
    }
}
