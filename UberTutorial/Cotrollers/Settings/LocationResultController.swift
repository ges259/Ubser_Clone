//
//  LocationResultController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/25.
//

import UIKit
import MapKit

final class LocationResultController: UITableViewController {
    
    // MARK: - Properties
    var delegate: LocationResultControllerDelegate?

    private var searchCompleter = MKLocalSearchCompleter()
    // 검색 결과 배열
    private var searchResults = [MKLocalSearchCompletion]()
    
    var type: LocationType = .home
    
    var searchTerm: String? {
        didSet {
            self.searchLocation(searchTerm: searchTerm ?? "")
        }
    }
    
    
    
    // MARK: - API
    private func setRegion() {
        guard let location = LocationHandler.shared.locationManager.location else { return }

        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        self.searchCompleter.region = region
    }
    
    private func searchLocation(searchTerm term: String) {
        searchCompleter.queryFragment = term
        
        self.searchResults = searchCompleter.results
        
        self.tableView.reloadData()
    }
    
    private func configureTableView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: TableViewIdentifier.justCell)
    }
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
        
        self.setRegion()
    }
}



// MARK: - extension
extension LocationResultController {
    // dataSorce
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: TableViewIdentifier.justCell)
        
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
        
        self.dismiss(animated: true)
        
        self.delegate?.searchResultLocation(locationString: locationString)
        
        print(locationString)
    }
}



// MARK: - UISearchBarDelegate
extension LocationResultController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색 텍스트가 변경될 때마다 -> 쿼리 조각을 설정. -> 테이블 뷰 업데이트
        self.searchCompleter.queryFragment = searchText
    }
}



// MARK: - MKLocalSearchCompleterDelegate
extension LocationResultController: MKLocalSearchCompleterDelegate {
    // 쿼리 조각을 -> 실제로 반환
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }
}
