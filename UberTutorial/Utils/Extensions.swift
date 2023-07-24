//
//  Extensions.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/17.
//

import UIKit
import MapKit



// MARK: - UIColor
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueColor = UIColor.rgb(red: 17, green: 154, blue: 237)
    static let outlineStrokeColor = UIColor.rgb(red: 234, green: 46, blue: 111)
    static let trackStrokeColor = UIColor.rgb(red: 56, green: 25, blue: 49)
    static let pulsatingFillColor = UIColor.rgb(red: 86, green: 30, blue: 63)
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
                   alignment: UIStackView.Alignment? = nil,
                   spacing: CGFloat? = nil)
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



// MARK: - UIButton
extension UIButton {

    func button(type: UIButton.ButtonType,
                title: String? = "",
                textColor: UIColor? = UIColor.black,
                backgroundColor: UIColor? = .clear,
                fontName: FontStyle? = .system,
                fontSize: CGFloat? = 18,
                image: String? = nil) {
        // type
        let btn = UIButton(type: type)

        // text
        if let title = title {
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.textColor = textColor
        }
        
        // font
        if let fontSize = fontSize {
            if fontName == .system {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            } else if fontName == .bold {
                btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
            } else {
                btn.titleLabel?.font = UIFont(name: "Avenir-Light", size: fontSize)
            }
        }

        // image
        if let image = image {
            btn.setImage(#imageLiteral(resourceName: image), for: .normal)
        }
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
                             paddingLeading: 8,
                             trailing: view.trailingAnchor,
                             paddingTrailing: 8,
                             centerY: view)
        }
        // Use SegmentedControl
        if let sc = segmentedControl {
            img.anchor(top: view.topAnchor,
                       paddingTop: -8,
                       leading: view.leadingAnchor,
                       paddingLeading: 8,
                       width: 24,
                       height: 24)
            
            view.addSubview(sc)
            sc.anchor(leading: view.leadingAnchor,
                      paddingLeading: 8,
                      trailing: view.trailingAnchor,
                      paddingTrailing: 8,
                      centerY: view,
                      paddingCenterY: 5)
        }
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(bottom: view.bottomAnchor,
                             leading: view.leadingAnchor,
                             paddingLeading: 8,
                             trailing: view.trailingAnchor,
                             height: 0.75)
        return view
    }
    
    
    
    // MARK: - Anchor
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                
                bottom: NSLayoutYAxisAnchor? = nil,
                paddingBottom: CGFloat = 0,
                
                leading: NSLayoutXAxisAnchor? = nil,
                paddingLeading: CGFloat = 0,
                
                trailing: NSLayoutXAxisAnchor? = nil,
                paddingTrailing: CGFloat = 0,
                
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                
                centerX: UIView? = nil,
                paddingCenterX: CGFloat = 0,
                
                centerY: UIView? = nil,
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
    
    
    
    // MARK: - backgroundColorView
    func backgrouncColorView(backgroundColor color: UIColor) -> UIView {
        let view = UIView()
        
        view.backgroundColor = color
        
        return view
    }
}



extension MKPlacemark {
    
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare else { return nil }
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else { return nil }
            guard let adminArea = administrativeArea else { return nil }
            
            return "\(subThoroughfare) \(thoroughfare) \(locality) \(adminArea)"
        }
    }
}



// MARK: - MapView
extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            
            let pointRect = MKMapRect(x: annotationPoint.x,
                                      y: annotationPoint.y,
                                      width: 0.01,
                                      height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        let insets = UIEdgeInsets(top: 120, left: 100, bottom: 350, right: 100)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    // 주석 만드는 코드
    func addAnnotationAndSelect(forPlacemark coordinate: CLLocationCoordinate2D) {
        // 주석 달기
        let anno = MKPointAnnotation()
        anno.coordinate = coordinate
        addAnnotation(anno)

        // 주석의 크기를 키우고 애니메이션을 추가
        selectAnnotation(anno, animated: true)
    }
}



// MARK: - UIViewController
extension UIViewController {
    
    
    
    // MARK: - presentAlertController
    func presentAlertController(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    // MARK: - shouldPresentLoadingView
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {

        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = UIColor.black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style =  UIActivityIndicatorView.Style.large
            indicator.color = .white
            indicator.center = self.view.center
            
            let label = UILabel()
            label.text = message
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 20)
            label.textAlignment = .center
            label.alpha = 0.87
            
            // loadingView만을 지울 것이기 때문에 loadingView 안에 레이아웃을 넣어야 함
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            
            self.view.addSubview(loadingView)
            
            label.anchor(top: indicator.bottomAnchor,
                         paddingTop: 32,
                         centerX: self.view)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            self.view.subviews.forEach { subViews in
                
                // 지우고싶은 뷰의 태그를 달아 해다 뷰만 지우는 과정
                if subViews.tag == 1 {
                    UIView.animate(withDuration: 0.3) {
                        subViews.alpha = 0
                    } completion: { _ in
                        subViews.removeFromSuperview()
                    }
                }
            }
        }
    }
}
