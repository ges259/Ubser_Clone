//
//  LocationInputCell.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import UIKit

final class LocationInputCell: UITableViewCell {
    
    
    
    // MARK: - Properties
    
    private var titleLabel: UILabel = {
        return UILabel().label(labelText: "123",
                               LabelTextColor: .darkGray,
                               fontName: .system,
                               fontSize: 14)
    }()
    private var addressLabel: UILabel = {
        return UILabel().label(labelText: "123132123123213131232",
                               LabelTextColor: .darkGray,
                               fontName: .system,
                               fontSize: 14)
    }()
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews: [self.titleLabel,
                                                self.addressLabel],
                                       axis: .vertical,
                                       distribution: .fillEqually,
                                       spacing: 4)
    }()
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        
        self.addSubview(self.stackView)
        self.stackView.anchor(leading: self.leadingAnchor,
                              paddingLeading: 12,
                              centerY: self)
        
        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
