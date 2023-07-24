//
//  SettingController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/24.
//

import UIKit

final class settingController: UITableViewController {
    
    
    // MARK: - Properties
    var user: User
    
    weak var delegate: SettingsControllerDelegate?
    
    var userInfoUpdated = false
    
    // location
    private let locationManager = LocationHandler.shared.locationManager
    
    private lazy var infoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 88, width: self.view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        
        return view
    }()
    
    
    
    // MARK: - Selectors
    @objc private func handleDismissal() {
        if userInfoUpdated {
            self.delegate?.updateUser(self)
            // 원상복구
            self.userInfoUpdated = false
        }
        
        self.dismiss(animated: true, completion: nil)
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
    private func configureTableView() {
        
        self.tableView.register(LocationInputCell.self, forCellReuseIdentifier: TableViewIdentifier.LocationTableViewIdentifier)
        self.tableView.backgroundColor = UIColor.white
        self.tableView.tableHeaderView = self.infoHeader
        
        self.tableView.tableFooterView = UIView()
    }
    
    private func configureNavigationBar() {
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.backgroundColor
        
        self.navigationController?.navigationBar.backgroundColor = .black
        
        self.navigationItem.title = "Settings"
        
        // back Button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismissal))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor
        
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.configureTableView()
        self.configureNavigationBar()
        
    }
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




// MARK: - TableVeiw Delegate
extension settingController {
    // dataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifier.LocationTableViewIdentifier, for: indexPath) as! LocationInputCell
        
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        
        
        cell.titleLabel.text = type.description
        cell.addressLabel.text = locationText(forType: type)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        guard let location = locationManager?.location else { return }
        
        let addLocationController = AddLocationController(type: type, location: location)
            // delegate
            addLocationController.delegate = self
            addLocationController.isModalInPresentation = true
        
        let nav = UINavigationController(rootViewController: addLocationController)
//        self.navigationController?.pushViewController(nav, animated: true)
        self.present(nav, animated: true)
    }
}



// MARK: - AddLocationControllerDelegate
extension settingController: AddLocationControllerDelegate {
    
    func updateLocation(locationString: String, type: LocationType) {
        
        PassengerService.shared.saveLocation(locationString: locationString,
                                             type: type) { error, ref in
            self.dismiss(animated: true, completion: nil)
            
            self.userInfoUpdated = true
            
            
            switch type {
            case .home:
                self.user.homeLocation = locationString
                
                
            case .work:
                self.user.workLocation = locationString
            }
            
            
            self.tableView.reloadData()
        }
    }
}



