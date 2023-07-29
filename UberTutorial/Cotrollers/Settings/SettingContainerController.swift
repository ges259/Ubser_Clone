//
//  SettingContainerController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/28.
//

import UIKit

final class SettingContainerController: UIViewController {
    
    // MARK: - Properties
    private var user : User? {
        didSet {
            
            guard let user = self.user else { return }
            self.configureSettingController(user: user)
        }
    }
    
    
    private lazy var xOrigin = self.view.frame.width - 80

    
    // controllers
    private var settingController: SettingController!
    private let addLocationController = AddLocationController()
    
    private var isExpanded: Bool = false
 
    
    
    
    // MARK: - Helper Functions
    private func configureSettingController(user: User) {
        
        self.settingController = SettingController(user: user)
        
        
        
        self.addChild(self.settingController)
        
        
        self.settingController.didMove(toParent: self)
        
        self.view.addSubview(self.settingController.view)
        
        
        
    }
    
    private func configureAddLocationController() {
        
        self.addLocationController.delegate = self
        
        self.addChild(self.addLocationController)
        
        self.addLocationController.didMove(toParent: self)
        
        self.view.insertSubview(self.addLocationController.view, at: 0)
        
        self.addLocationController.view.frame = CGRect(x: 0,
                                                       y: 40,
                                                       width: self.view.frame.width,
                                                       height: self.view.frame.height - 40)
    }
    
    private func animateAddLocationController(shouldExpand: Bool, type: LocationType? = nil, completion: ((Bool) -> Void)? = nil) {
        
        
        if shouldExpand {
            guard let type = type else { return }
            self.addLocationController.type = type
            
            UIView.animate(withDuration: 0.3,
                           delay: 0.8,
                           options: .curveEaseInOut,
                           animations: {
                print(#function)
                self.settingController.view.frame.origin.x = self.xOrigin
            },completion: nil)
            
            
        } else {
            UIView.animate(withDuration: 0.3,
                           delay: 0.8,
                           options: .curveEaseInOut,
                           animations: {
                print(#function)
                self.settingController.view.frame.origin.x = 0
            },completion: nil)
        }
    }
    
    
    
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.settingController.delegate = self
        self.configureAddLocationController()
        
        
    }
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension SettingContainerController: SettingContainerDelegate2 {
    
    func didSelectedCell(type: LocationType) {
        print(#function)
        print("fdasl;jghbnsakj;hgbn;asdkjhg;asfjkhg;fkkjh")

        self.isExpanded.toggle()
        
//        self.animateAddLocationController(shouldExpand: true, type: type) { _ in
//            switch type {
//            case .home:
//                print(#function)
//                break
////                self.navigationController?.pushViewController(self.addLocationController, animated: true)
//            case .work:
//                print(#function)
//                break
////                self.navigationController?.pushViewController(self.addLocationController, animated: true)
//            }
//        }
    }
}


extension SettingContainerController: AddLocationControllerDelegate2 {
    func popToSetting() {
        self.isExpanded.toggle()
        print(#function)
        self.animateAddLocationController(shouldExpand: self.isExpanded)
    }
}


