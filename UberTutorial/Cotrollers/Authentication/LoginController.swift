//
//  LoginController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/17.
//

import UIKit
import FirebaseAuth

final class LoginController: UIViewController {
    
    // MARK: - ImageView
    private let emailImageView: UIImageView = {
        return UIImageView()
    }()

    
    
    // MARK: - Label
    private let titleLabel: UILabel = {
        return UILabel().label(labelText: "UBER",
                               LabelTextColor: UIColor(white: 1, alpha: 0.8),
                               fontName: .system,
                               fontSize: 36)
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
    
    
    
    // MARK: - TextField
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email")
    }()
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "pasword",
                                       isSecureTextEntry: true)
    }()
    
    
    
    // MARK: - Button
    private lazy var loginButton: UIButton = {
        let btn = UIButton().button(title: "Log In",
                                    fontName: .bold,
                                    fontSize: 20,
                                    Auth: true)
        
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return btn
    }()
    private lazy var dontHaveAccountButton: UIButton = {
        let btn = UIButton().mutableAttributedString(
            buttonType: .system,
            
            type1TextString: "Don't have an account?   ",
            type1FontName: .system,
            type1FontSize: 16,
            type1Foreground: UIColor.lightGray,
            
            type2TextString: "Sign Up",
            type2FontName: .bold,
            type2FontSize: 16,
            type2Foreground: UIColor.mainBlueColor)
        
        btn.addTarget(self, action: #selector(HandleShowSignUp), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(
            arrangedSubviews: [self.emailContainerView,
                               self.passwordContainerView,
                               self.loginButton],
            axis: .vertical,
            distribution: .fillEqually,
            alignment: .fill,
            spacing: 16)
    }()
    
    
    
    // MARK: - Selectors
    @objc private func HandleShowSignUp() {
        let signUpController = SignUpController()
        
        navigationController?.pushViewController(signUpController, animated: true)
    }
    @objc private func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            // error
            if let error = error {
                print("DEGUB: Failed to log  user in with error \(error.localizedDescription)")
                return
            }

            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? ContainerController else { return }
            
            // mapkit 활성화
            controller.configure()
            
            // HomeController로 이동
            self.dismiss(animated: true)
            print("Successfully logged user in")
        }
    }
    
    
    
    // MARK: - Configure UI
    private func configureUI() {
        // configure navigation bar
        self.configureNavigationBar()
        
        // set background color
        self.view.backgroundColor = UIColor.backgroundColor
        
        
        // configure UI
        self.view.addSubview(self.titleLabel)
        self.titleLabel.anchor(top: self.view.topAnchor, paddingTop: 55,
                               centerX: self.view)
        
        self.view.addSubview(self.stackView)
        self.stackView.anchor(top: self.titleLabel.bottomAnchor,
                              paddingTop: 40,
                              leading: self.view.leadingAnchor,
                              paddingLeading: 16,
                              trailing: self.view.trailingAnchor,
                              paddingTrailing: 16)
        
        self.view.addSubview(self.dontHaveAccountButton)
        self.dontHaveAccountButton.anchor(bottom: self.view.safeAreaLayoutGuide.bottomAnchor,
                                          height: 32,
                                          centerX: self.view)
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI
        self.configureUI()
    }
}
