//
//  LocationInputActivationView.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import UIKit

final class LocationInputActivationView: UIView {
    
    // MARK: - Properties
    weak var delegate: LocationInputActivationViewDelegate?
    
    
    
    // MARK: - View
    private let indicatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: .black)
    }()
    
    
    
    // MARK: - Label
    private let placeholderLabel: UILabel = {
        let lbl = UILabel ()
        
        lbl.text = "Where to?"
        lbl.font = UIFont.systemFont(ofSize: 18)
        lbl.textColor = UIColor.darkGray
        
        return lbl
    }()
    
    
    
    // MARK: - Selector
    @objc private func handleShowLocationView() {
        delegate?.presentLocationInputView()
    }
    
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // set background colors
        self.backgroundColor = UIColor.white
        
        self.addShadow()
        
        // autoLayout
        self.addSubview(self.indicatorView)
        self.indicatorView.anchor(leading: self.leadingAnchor,
                                  paddingLeading: 16,
                                  width: 6,
                                  height: 6,
                                  centerY: self)
        
        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.anchor(leading: self.indicatorView.trailingAnchor,
                                  paddingLeading: 20,
                                  centerY: self)
        
        // add Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowLocationView))
        self.addGestureRecognizer(tap)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
