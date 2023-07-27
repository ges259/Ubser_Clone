//
//  SignUpController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/18.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GeoFire

final class SignUpController: UIViewController {
    
    // MARK: - Properties
    private var location = LocationHandler.shared.locationManager.location
    
    
    
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
        return UITextField().textField(withPlaceholder: "Email",
                                       keyboardType: .emailAddress)
    }()
    private let fullNameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "FullName")
    }()
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "pasword", isSecureTextEntry: true)
    }()
    
    
    
    // MARK: - Button
    private lazy var signUpButton: UIButton = {
        let btn = UIButton().button(title: "Sign Up",
                                    fontName: .bold,
                                    fontSize: 20,
                                    Auth: true)
        btn.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return btn
    }()
    private lazy var alreadyHaveButton: UIButton = {
        let btn = UIButton().mutableAttributedString(
            buttonType: .system,
            
            type1TextString: "Already have an account?   ",
            type1FontName: .system,
            type1FontSize: 16,
            type1Foreground: UIColor.lightGray,
            
            type2TextString: "Sign In",
            type2FontName: .bold,
            type2FontSize: 16,
            type2Foreground: UIColor.mainBlueColor)
 
        btn.addTarget(self, action: #selector(HandleShowLogin), for: .touchUpInside)
        
        return btn
    }()

    
    
    // MARK: - SegmentControl
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        
        sc.backgroundColor = UIColor.backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        
        return sc
    }()
                                               
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews:
                                        [self.emailContainerView,
                                         self.passwordContainerView,
                                         self.fullNameContainerView,
                                         self.accountTypeContainerView,
                                         self.signUpButton],
                                       axis: .vertical,
                                       distribution: .fill,
                                       alignment: .fill,
                                       spacing: 24)
    }()
    
    
    
    // MARK: - Selectors
    @objc private func HandleShowLogin() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            // error
            if let error = error {
                print("Frailed to register user with error \(error)")
                return
            }
            
            // 유저의 아이디 불러오기
            guard let uid = result?.user.uid else { return }
            
            // dictionary 만들기
            let values = [DB_String.email: email,
                          DB_String.fullName: fullName,
                          DB_String.accountType: accountTypeIndex] as [String: Any]
            
            // 운전자일 경우
            if accountTypeIndex == 1 {
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self.location else { return }
                
                geofire.setLocation(location, forKey: uid) { error in
                    self.updateUserDataAndShowHomeController(uid: uid, values: values)
                }
            }
            self.updateUserDataAndShowHomeController(uid: uid, values: values)
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func updateUserDataAndShowHomeController(uid: String, values: [String: Any]) {
        // dictionary를 바탕으로 uid에 유저에 관한 정보 업데이트
        REF_USERS.child(uid).updateChildValues(values) { error, ref in
            
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? ContainerController else { return }
            
            // mapkit 활성화
            controller.configure()
            
            // HomeController로 이동
            self.dismiss(animated: true)
            print("Successfully registerd user and saved data..")
        }
    }
    
    
    
    // MARK: - configure UI
    private func configureUI() {
        
        // set background color
        self.view.backgroundColor = UIColor.backgroundColor
        
        // configure UI
        self.view.addSubview(self.titleLabel)
        self.titleLabel.anchor(top: self.view.topAnchor,
                               paddingTop: 55,
                               centerX: self.view)
        
        self.view.addSubview(self.stackView)
        self.stackView.anchor(top: self.titleLabel.bottomAnchor,
                              paddingTop: 40,
                              leading: self.view.leadingAnchor,
                              paddingLeading: 16,
                              trailing: self.view.trailingAnchor,
                              paddingTrailing: 16)
        
        self.view.addSubview(self.alreadyHaveButton)
        self.alreadyHaveButton.anchor(bottom: self.view.safeAreaLayoutGuide.bottomAnchor,
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
        
        // configure navigation bar
        self.configureNavigationBar()
        
        // configure UI
        self.configureUI()
    }
}
