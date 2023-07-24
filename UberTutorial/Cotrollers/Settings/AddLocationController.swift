//
//  AddLocationController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/25.
//

import UIKit
import MapKit

final class AddLocationController: UITableViewController {
    
    
    // MARK: - Properties
    weak var delegate: AddLocationControllerDelegate?

    private let searchBar = UISearchBar()
 
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet {
            // 테이블뷰에 표시하기 위해 talbeView.reloadData
            self.tableView.reloadData()
        }
    }
    
    
    
    private let type: LocationType
    private let location: CLLocation
    
    
    
    
    // MARK: - Helper Functions
    
    
    
    
    
    
    
    // MARK: - Configure UI
    private func configureTableView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: TableViewIdentifier.justCell)
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.addShadow()
        
    }
    
    
    private func configureSearchBar() {
        self.searchBar.sizeToFit()
        self.searchBar.delegate = self
        navigationItem.titleView = self.searchBar
    }
    
    private func configureSearchCompletor() {
        self.searchCompleter.delegate = self
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        self.searchCompleter.region = region
        
    }
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.configureTableView()
        
        self.configureSearchBar()
        
        self.configureSearchCompletor()
        
        
    }
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - TableView
extension AddLocationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: TableViewIdentifier.justCell)
        
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        
        return cell
    }
    
    // delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let result = searchResults[indexPath.row]
        let title = result.title
        let subtitle = result.subtitle
        let locationString = "\(title) \(subtitle)"
        
        self.delegate?.updateLocation(locationString: locationString, type: self.type)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}



// MARK: - UISearchBarDelegate
extension AddLocationController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색 텍스트가 변경될 때마다 -> 쿼리 조각을 설정. -> 테이블 뷰 업데이트
        searchCompleter.queryFragment = searchText
    }
}



// MARK: - MKLocalSearchCompleterDelegate
extension AddLocationController: MKLocalSearchCompleterDelegate {
    // 쿼리 조각을 -> 실제로 반환
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }
}


