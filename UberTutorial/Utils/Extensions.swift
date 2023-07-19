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
    
    func textField(withPlaceholder placeholder: String,
                   isSecureTextEntry: Bool? = false,
                   backgroundColor: UIColor? = UIColor.clear,
                   textColor: UIColor? = .white,
                   fontSize: CGFloat? = 16,
                   keyboardType: UIKeyboardType = .webSearch,
                   paddingLeftView: Bool? = false)
    
    -> UITextField {
        
        let tf = UITextField()
        
        
        // set keyboardType
        tf.keyboardType = keyboardType
        
        // set text color
        tf.textColor = textColor
        
        // set font size
        tf.font = UIFont.systemFont(ofSize: fontSize!)
        
        // set background color
        tf.backgroundColor = backgroundColor
        
        // set placeholder
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        // padding Left View
        if paddingLeftView! {
            let paddingView = UIView()
            paddingView.anchor(width: 8, height: 30)
            tf.leftView = paddingView
            tf.leftViewMode = .always
        }
        
        
        
        tf.borderStyle = .none
        
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        
        tf.isSecureTextEntry = isSecureTextEntry ?? false
        tf.textContentType = .oneTimeCode
        
        return tf
    }
}


// MARK: - enum
enum FontStyle {
    case system
    case bold
    case AvenirLight
}


// MARK: - UILabel
extension UILabel {
    
    func label(labelText: String? = nil,
               LabelTextColor: UIColor? = .darkGray,
               fontName: FontStyle? = .system,
               fontSize: CGFloat? = nil)
    -> UILabel {
        
        let lbl = UILabel()
        
        // text
        if let labelText = labelText {
            lbl.text = labelText
            lbl.textColor = LabelTextColor
        }
        // font
        if let fontSize = fontSize {
            if fontName == .system {
                lbl.font = UIFont.systemFont(ofSize: fontSize)
            } else if fontName == .bold {
                lbl.font = UIFont.boldSystemFont(ofSize: fontSize)
            } else {
                lbl.font = UIFont(name: "Avenir-Light", size: fontSize)
            }
        }
        
        return lbl
    }
}



// MARK: - UIStackView

extension UIStackView {
    
    func stackView(arrangedSubviews: [UIView],
                   axis: NSLayoutConstraint.Axis? = .vertical,
                   distribution: UIStackView.Distribution? = nil,
                   spacing: CGFloat? = nil,
                   alignment: UIStackView.Alignment? = nil)
    -> UIStackView {
        
        let stv = UIStackView(arrangedSubviews: arrangedSubviews)
        
        if let axis = axis {
            stv.axis = axis
        }
        if let distribution = distribution {
            stv.distribution = distribution
        }
        if let spacing = spacing {
            stv.spacing = spacing
        }
        if let alignment = alignment {
            stv.alignment = alignment
        }
        return stv
    }
}









//// MARK: - UIButton
//extension UIButton {
//
//    func button(type: UIButton.ButtonType,
//                title: String? = "",
//                textColor: UIColor? = UIColor.black,
//                fontName: FontStyle? = .system,
//                fontSize: CGFloat? = 18,
//                image: String? = nil) {
//        // type
//        let btn = UIButton(type: type)
//
//        // text
//        if let title = title {
//            btn.setTitle(title, for: .normal)
//            btn.titleLabel?.textColor = textColor
//        }
//
//        // font
//        if let fontSize = fontSize {
//            if fontName == .system {
//                btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
//            } else if fontName == .bold {
//                btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
//            } else {
//                btn.titleLabel?.font = UIFont(name: "Avenir-Light", size: fontSize)
//            }
//        }
//
//        // image
//        if let image = image {
//            btn.setImage(#imageLiteral(resourceName: image), for: .normal)
//        }
//    }
//}















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
    
    
    
    
    // MARK: - Shadow
    func addShadow() {
        // shadow setting
        self.layer.shadowColor = UIColor.black.cgColor
        // 그림자를 얼마나 어둡게 할지
        self.layer.shadowOpacity = 0.45
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.masksToBounds = false
    }
    
    
    
    func backgrouncColorView(backgroundColor color: UIColor) -> UIView {
        let view = UIView()
        
        view.backgroundColor = color
        
        return view
    }
}



