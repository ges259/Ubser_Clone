//
//  SettingController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/24.
//

import UIKit
import CoreLocation

final class SettingController: UIViewController {
    
    
    // MARK: - Properties
    var user: User
    
//    weak var delegate: SettingsControllerDelegate?
    
    var type: LocationType?
    weak var delegate: SettingContainerDelegate2?
    
    private let addLocationController = UINavigationController(rootViewController: AddLocationController())
    
    // location
    private let locationManager = LocationHandler.shared.locationManager
    
    private lazy var infoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 88, width: self.view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        
        return view
    }()
    
    
    
    
    // MARK: - Layout
    private lazy var homeButton: UIButton = {
        let btn = UIButton().button(title: "Home",
                                    titleColor: UIColor.black,
                                    fontName: .system,
                                    fontSize: 20)
        
        btn.subtitleLabel?.text = "Home Location"
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 80).isActive = true
        btn.addTarget(self, action: #selector(homeLocation), for: .touchUpInside)
        
        return btn
    }()
    private lazy var workButton: UIButton = {
        let btn = UIButton().button(title: "Work",
                                    titleColor: UIColor.black,
                                    fontName: .system,
                                    fontSize: 20)
        
        btn.subtitleLabel?.text = "Work Location"
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        btn.addTarget(self, action: #selector(workLocation), for: .touchUpInside)
        
        return btn
    }()
    
    
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews: [self.homeButton,
                                                          self.workButton],
                                       axis: .vertical,
                                       distribution: .fillEqually,
                                       alignment: .fill,
                                       spacing: 1)
    }()
    
    private let blackView: UIView = {
        let blackView = UIView().backgrouncColorView(backgroundColor: UIColor.backgroundColor)
        
        let title = UILabel().label(labelText: "Favorites",
                                    LabelTextColor: .white,
                                    fontName: .system,
                                    fontSize: 16)
        blackView.addSubview(title)
        title.anchor(leading: blackView.leadingAnchor,
                     paddingLeading: 16,
                     centerY: blackView)
        
        return blackView
    }()
    
    
    
    
    
    // MARK: - Selectors
    @objc private func handleDismissal() {
        self.dismiss(animated: true, completion: nil)
        
    }
    @objc private func homeLocation() {
//        guard let type = self.type else { return }
//        self.delegate?.didSelectedCell(type: type)
        
        let controller = AddLocationController()
        controller.delegate1 = self
        controller.type = .home
        
//        self.delegate?.didSelectedCell(type: .home)
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @objc private func workLocation() {
        guard let type = self.type else { return }
        self.delegate?.didSelectedCell(type: type)
    }
    
    
    
    // MARK: - Helper Functions
    private func locationText(forType type: LocationType) -> String {
        switch type {
        case .home:
            return self.user.homeLocation ?? type.subtitle
        case .work:
            return self.user.workLocation ?? type.subtitle
        }
    }
    
    
    
    // MARK: - Configure UI
    
    private func configureNavigationBar() {
        self.navigationItem.title = "Settings"

//        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false

        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.backgroundColor

        self.navigationController?.navigationBar.backgroundColor = .black

        // back Button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismissal))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.configureNavigationBar()
        
        
        self.configureUI()
    }
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configure UI
    private func configureUI() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.infoHeader)
        self.infoHeader.anchor(top: self.view.topAnchor, paddingTop: 0,
                               leading: self.view.leadingAnchor, paddingLeading: 0,
                               trailing: self.view.trailingAnchor, paddingTrailing: 0,
                               height: 100)
        
        self.view.addSubview(self.blackView)
        self.blackView.anchor(top: self.infoHeader.bottomAnchor, paddingTop: 1,
                              leading: self.view.leadingAnchor, paddingLeading: 0,
                              trailing: self.view.trailingAnchor, paddingTrailing: 0,
                              height: 30)
        
        self.view.addSubview(self.stackView)
        self.stackView.anchor(top: self.blackView.bottomAnchor, paddingTop: 1,
                              leading: self.view.leadingAnchor, paddingLeading: 0,
                              trailing: self.view.trailingAnchor, paddingTrailing: 0)
    }
}




// MARK: - TableVeiw Delegate
//extension SettingController {
//    // dataSource
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return LocationType.allCases.count
//    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifier.LocationTableViewIdentifier, for: indexPath) as! LocationInputCell
//
//        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
//
//        cell.titleLabel.text = type.description
//        cell.addressLabel.text = locationText(forType: type)
//
//        return cell
//    }
//
//    // header dataSource
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let blackView = UIView().backgrouncColorView(backgroundColor: UIColor.backgroundColor)
//
//        let title = UILabel().label(labelText: "Favorites",
//                                    LabelTextColor: .white,
//                                    fontName: .system,
//                                    fontSize: 16)
//        blackView.addSubview(title)
//        title.anchor(leading: blackView.leadingAnchor,
//                     paddingLeading: 16,
//                     centerY: blackView)
//
//        return blackView
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    // delegate
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let type = LocationType(rawValue: indexPath.row) else { return }
//
//        self.type = type
//
//
//
//
//        print(#function)
////
//        let controller = AddLocationController()
////        controller.delegate = self
//////
////        controller.type = type
////
////        self.navigationController?.pushViewController(controller, animated: true)
//
//
//    }
//}



// MARK: - AddLocationControllerDelegate
extension SettingController: AddLocationControllerDelegate {
    
    func updateLocation(locationString: String, type: LocationType) {
        
        PassengerService.shared.saveLocation(locationString: locationString,
                                             type: type) { error, ref in
            
            switch type {
            case .home:
                print("dfsafsd11111111111")
                self.user.homeLocation = locationString
                
                
            case .work:
                print("dfsafsd2222222222222")
                self.user.workLocation = locationString
            }
            
//            self.delegate?.updateUser(self)
            
//            self.tableView.reloadData()
        }
    }
}







