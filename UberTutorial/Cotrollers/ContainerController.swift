//
//  ContainerController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/24.
//

import UIKit
import Firebase

final class ContainerController: UIViewController {
    
    // MARK: - Properties
    
    private let homeController = HomeController()
    private var menuController: MenuController!
    private let blackView = UIView()
    
    private var isExpanded = false
    
    private lazy var xOrigin = self.view.frame.width - 80

    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            self.homeController.user = user
            self.configureMenuController(withUser: user)
        }
    }
    
    // MARK: - Selectors
    
    @objc private func dismissMenu() {
        self.isExpanded = false
        self.animateMenu(shouldExpand: self.isExpanded)
    }
    
    
    
    
    // MARK: - API
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    // check Login
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User is not logged in")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                    nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            print("DEBUG: User is logged in")
            self.configure()
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func configureHomeController() {
        // delegate
        self.homeController.delegate = self
        // addChild: 특정 ViewController를 현재 ViewController의 자식으로 설정
            // 추후에 child 사용을 대비하여 넣어놓는 것
        self.addChild(self.homeController)
        
        // childVC입장에서는 언제 parentVC에 추가되는지 모르기 때문에.
            // childVC에게 추가 및 제거 되는 시점을 알려주는 것
                // ( didMove - 추가 전 / willMove - 추가 후 )
        self.homeController.didMove(toParent: self)
        
        // 추가된 childVC의 View가 보일 수 있도록 맨 앞으로 등장하게 하는 것
        self.view.addSubview(self.homeController.view)
    }
    
    private func configureMenuController(withUser user: User) {
        // MenuController 생성
        self.menuController = MenuController(user: user)
        
        // delegate 설정
        self.menuController.delegate = self
        
        self.addChild(self.menuController)
        self.menuController.didMove(toParent: self)
        // 뷰에 계층 구조를 만듦
            // 홈컨트롤러는 최상위 계층에 있고
            // 메뉴컨트롤러는 중간계층에 있도록 만듦
            // 순서: 컨테이너 - 메뉴 - 홈(최상위)
                // 메뉴컨트롤러 ----- at: 0 <<<<<---- 홈컨트롤러 밑에
                // 홈컨트롤러 ----- at: 1
        // menuController를 뷰의 0번째에 삽입
        self.view.insertSubview(self.menuController.view, at: 0)
        // menuController 설정
        self.menuController.view.frame = CGRect(x: 00,
                                                y: 40,
                                                width: self.view.frame.width,
                                                height: self.view.frame.height - 40)
        // 오른쪽 빈공간에 blackView 만들기
        self.configureBlackView()
    }
    
    
    
    
    private func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        
        // menuController가 나옴
        if shouldExpand {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
                self.moveBlackView(shouldShrink: shouldExpand)
            },completion: nil)

            
        // menuController가 들어감
        } else {
            self.blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: {
                self.homeController.view.frame.origin.x = 0
                self.moveBlackView(shouldShrink: shouldExpand)
            },completion: completion)
        }
        self.animateStatusBar()
    }
    
    
    // sign out
    private func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                    nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("DEBUG: Error signin out")
        }
    }
    
    
    private func configureBlackView() {
        self.blackView.frame = CGRect(x: 0,
                                      y: 0,
                                      width: self.view.frame.width,
                                      height: self.view.frame.height)
        self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.blackView.alpha = 0
        self.view.addSubview(self.blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        self.blackView.addGestureRecognizer(tap)
    }
    
    
    private func moveBlackView(shouldShrink: Bool) {
        if shouldShrink {
            self.blackView.alpha = 1
            self.blackView.frame.origin.x = self.xOrigin
        } else {
            self.blackView.alpha = 0
            self.blackView.frame.origin.x = 0
        }
    }
    
    private func animateStatusBar() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    
    
    
    
    
    
    
    func configure() {
        // headerView의 윗부분에 검정색을 가리기 위해 필요
        self.view.backgroundColor = UIColor.backgroundColor
        
        self.configureHomeController()
        
        self.fetchUserData()
    }
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkIfUserIsLoggedIn()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}



// MARK: - HomeControllerDelegate
extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
        self.isExpanded.toggle()
        self.animateMenu(shouldExpand: self.isExpanded)
    }
}




// MARK: - MenuControllerDelegate
extension ContainerController: MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        self.isExpanded.toggle()
        
        self.animateMenu(shouldExpand: self.isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
                
                
            case .settings:
                guard let user = self.user else { return }
                
                let settingController = SettingController(user: user)
                // delegate
//                settingController.delegate = self
                
                let nav = UINavigationController(rootViewController: settingController)
                
                self.present(nav, animated: true, completion: nil)
                
                
            case .logout:
                let alert = UIAlertController(title: nil,
                                              message: "Are you sure you want to log out?",
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Log Out",
                                              style: .destructive,
                                              handler: { _ in
                    self.signOut()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
    }
}



// MARK: - SettingsControllerDelegate
extension ContainerController: SettingsControllerDelegate {
    
    func updateUser(_ controller: SettingController) {
        self.user = controller.user
    }
}
