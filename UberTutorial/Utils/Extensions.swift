//
//  Extensions.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/17.
//

import UIKit



// MARK: - UIColor
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueColor = UIColor.rgb(red: 17, green: 154, blue: 237)
}



// MARK: - TextField
extension UITextField {
    func textField(withPlaceholer placeholer: String, isSecureTextEntry: Bool) -> UITextField {
        let tf = UITextField()
        
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholer,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = isSecureTextEntry
        return tf
    }
}









// MARK: - UIView
extension UIView {
    
    
    // MARK: - Login - ContainerView
    func inputContainerView(image: UIImage,
                            textField: UITextField? = nil,
                            segmentedControl: UISegmentedControl? = nil) -> UIView {
        
        let view = UIView()
        
        let img = UIImageView()
        img.image = image
        img.alpha = 0.87
        view.addSubview(img)
        
        
        // Use TextField
        if let textField = textField {
            img.anchor(leading: view.leadingAnchor,
                       paddingLeading: 8,
                       width: 24,
                       height: 24,
                       centerY: view)
            
            view.addSubview(textField)
            textField.anchor(leading: img.trailingAnchor,
                             trailing: view.trailingAnchor,
                             paddingLeading: 8,
                             paddingTrailing: 8,
                             centerY: view)
        }
        // Use SegmentedControl
        if let sc = segmentedControl {
            img.anchor(top: view.topAnchor,
                       leading: view.leadingAnchor,
                       paddingTop: -8,
                       paddingLeading: 8,
                       width: 24,
                       height: 24)
            
            view.addSubview(sc)
            sc.anchor(leading: view.leadingAnchor,
                      trailing: view.trailingAnchor,
                      paddingLeading: 8,
                      paddingTrailing: 8,
                      centerY: view,
                      paddingCenterY: 5)
        }
        
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(bottom: view.bottomAnchor,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             paddingLeading: 8,
                             height: 0.75)
        
        
        return view
    }
    
    
    // MARK: - Anchor
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                
                paddingTop: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingLeading: CGFloat = 0,
                paddingTrailing: CGFloat = 0,
                
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                
                centerX: UIView? = nil,
                centerY: UIView? = nil,
                
                paddingCenterX: CGFloat = 0,
                paddingCenterY: CGFloat = 0) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX.centerXAnchor, constant: paddingCenterX).isActive = true
        }
        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY.centerYAnchor, constant: paddingCenterY).isActive = true
        }
    }
}



