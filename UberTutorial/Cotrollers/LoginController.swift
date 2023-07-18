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
        let img = UIImageView()
        
        return img
    }()
    
    
    
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
    
    
    
    // MARK: - TextField
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email")
    }()
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "pasword", isSecureTextEntry: true)
    }()
    
    
    
    // MARK: - Button
    private let loginButton: AuthButton = {
        let btn = AuthButton(type: .system)
        
        btn.setTitle("Log In", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return btn
    }()
    private let dontHaveAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(
            string: "Don't have an account?   ",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                         NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        )
        attributedTitle.append(NSAttributedString(
            string: "Sign Up",
            attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
                         NSAttributedString.Key.foregroundColor : UIColor.mainBlueColor])
        )
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        btn.addTarget(self, action: #selector(HandleShowSignUp), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [self.emailContainerView,
                                                 self.passwordContainerView,
                                                 self.loginButton])
        stv.spacing = 16
        stv.axis = .vertical
        stv.distribution = .fillEqually
        stv.alignment = .fill
        
        return stv
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

            
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else { return }
            
            // mapkit 활성화
            controller.configureUI()
            
            // HomeController로 이동
            self.dismiss(animated: true)
            print("Successfully logged user in")
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    // MARK: - Helper Functions
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
                              leading: self.view.leadingAnchor,
                              trailing: self.view.trailingAnchor,
                              paddingTop: 40,
                              paddingLeading: 16,
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