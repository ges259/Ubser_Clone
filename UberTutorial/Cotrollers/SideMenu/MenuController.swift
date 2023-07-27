//
//  MenuController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/24.
//

import UIKit

final class MenuController: UITableViewController {
    
    // MARK: - Properties
    private let user: User
    // ContainerController
    weak var delegate: MenuControllerDelegate?
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width,
                           height: 140)
                            // 10999. width: self.view.frame.width - 80,
        // MenuHeader 생성
        let view = MenuHeader(user: self.user,frame: frame)
        return view
    }()
    
    
    
    
    
    // MARK: - Selectors
    
    
    
    
    
    
    // MARK: - Helper Functions
    
    private func configureTableView() {
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .red
        
        self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .none
        self.tableView.isScrollEnabled = false
        
        // tableView register
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: TableViewIdentifier.MenuTableViewIdentifier)
        // tableView header register
        self.tableView.tableHeaderView = self.menuHeader
    }
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.configureTableView()
    }
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - DataSource / Delegate
extension MenuController {
    // dataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifier.MenuTableViewIdentifier, for: indexPath)

        guard let options = MenuOptions(rawValue: indexPath.row) else { return UITableViewCell() }
        
        cell.textLabel?.text = options.description
        
        return cell
    }
    
    
    
    // delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = MenuOptions(rawValue: indexPath.row) else { return }
        
        self.delegate?.didSelect(option: option)
    }
}
