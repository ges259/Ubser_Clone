//
//  MenuHeader.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/24.
//

import UIKit

final class MenuHeader: UIView {
    
    // MARK: - Properties
    private let user: User
    
    
    
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
                               LabelTextColor: .white,
                               fontName: .system,
                               fontSize: 16)
    }()
    private lazy var emailLabel: UILabel = {
        return UILabel().label(labelText: self.user.email,
                               LabelTextColor: .white,
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
    
    
    
    
    
    // MARK: - Selectors
    
    
    
    
    
    
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
        self.backgroundColor = .backgroundColor
        
        // profileImageView
        self.addSubview(self.profileView)
        self.profileView.clipsToBounds = true
        self.profileView.layer.cornerRadius = 64 / 2
        self.profileView.anchor(top: self.safeAreaLayoutGuide.topAnchor,
                                     paddingTop: 0,
                                     leading: self.leadingAnchor,
                                     paddingLeading: 12,
                                     width: 64,
                                     height: 64)
        
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
