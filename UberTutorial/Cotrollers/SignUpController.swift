//
//  SignUpController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/18.
//

import UIKit

final class SignUpController: UIViewController {
    
    
    
    
    
    // MARK: - Properties
    
    
    
    
    
    // MARK: - Label
    private let titleLabel: UILabel = {
        let lbl = UILabel ()
        
        lbl.text = "UBER"
        lbl.font = UIFont(name: "Avenir-Light", size: 36)
        lbl.textColor = UIColor(white: 1, alpha: 0.8)
        
        return lbl
    }()
    
    
    
    
    // MARK: - View
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"),
                                               textField: self.emailTextField)
        view.anchor(height: 50)
        return view
    }()
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"),
                                               textField: self.passwordTextField)
        view.anchor(height: 50)
        return view
    }()
    private lazy var fullNameContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"),
                                               textField: self.fullNameTextField)
        view.anchor(height: 50)
        return view
    }()
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"),
                                               segmentedControl: accountTypeSegmentedControl)
        view.anchor(height: 80)
        return view
    }()
    
    
    
    
    // MARK: - TextField
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholer: "Email", isSecureTextEntry: false)
    }()
    private let fullNameTextField: UITextField = {
        return UITextField().textField(withPlaceholer: "FullName", isSecureTextEntry: false)
    }()
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholer: "pasword", isSecureTextEntry: true)
    }()
    
    
    
    // MARK: - Button
    private let signUpButton: AuthButton = {
        let btn = AuthButton(type: .system)
        
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)

        return btn
    }()
    private let alreadyHaveButton: UIButton = {
        let btn = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(
            string: "Already have an account?   ",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                         NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        )
        attributedTitle.append(NSAttributedString(
            string: "Sign In",
            attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
                         NSAttributedString.Key.foregroundColor : UIColor.mainBlueColor])
        )
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        btn.addTarget(self, action: #selector(HandleShowLogin), for: .touchUpInside)
        
        return btn
    }()

    
    // MARK: - SegmentControl
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
                                               
                                               
    
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [self.emailContainerView,
                                                 self.passwordContainerView,
                                                 self.fullNameContainerView,
                                                 self.accountTypeContainerView,
                                                 self.signUpButton])
        stv.spacing = 24
        stv.axis = .vertical
        stv.distribution = .fill
        stv.alignment = .fill
        
        return stv
    }()
    
    
    
    
    // MARK: - Selectors
    @objc private func HandleShowLogin() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - Helper Functions
    private func configureUI() {
        
        // set background color
        self.view.backgroundColor = UIColor.backgroundColor
        
        
        // configure UI
        self.view.addSubview(self.titleLabel)
        self.titleLabel.anchor(top: self.view.topAnchor, paddingTop: 55,
                               centerX: self.view)
        
        self.view.addSubview(self.stackView)
        self.stackView.anchor(top: self.titleLabel.bottomAnchor,
                              leading: self.view.leadingAnchor,
                              trailing: self.view.trailingAnchor,
                              paddingTop: 40,
                              paddingLeading: 16,
                              paddingTrailing: 16)
        
        self.view.addSubview(self.alreadyHaveButton)
        self.alreadyHaveButton.anchor(bottom: self.view.safeAreaLayoutGuide.bottomAnchor,
                                      height: 32,
                                      centerX: self.view)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
    }
}
