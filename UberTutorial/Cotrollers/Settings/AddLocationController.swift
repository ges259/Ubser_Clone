//
//  AddLocationController.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/25.
//

import UIKit
import MapKit

final class AddLocationController: UIViewController {
    
    
    // MARK: - Properties
    
    lazy var type: LocationType = .home
    
    // settingController
    weak var delegate: AddLocationControllerDelegate?
    
    
    
    private let localResultController = LocationResultController()


    private let searchResultController = UISearchController(searchResultsController: LocationResultController())
    
    private var searchResults = [MKLocalSearchCompletion]()

    private lazy var textLabel: UILabel = {
        return UILabel().label(labelText: "\(String(describing: type.koreanString))의 위치를 설정하세요", LabelTextColor: UIColor.black)
    }()
    
    
    
    
    
    
    
    // MARK: - Helper Functions
    
    
    
    
    
    
    
    // MARK: - Configure UI

    private func configureNavigation() {
        self.navigationItem.title = "Find Location"

        self.navigationController?.navigationBar.barStyle = .black
    }
    
    private func configureSearchResultBar() {
        self.navigationItem.searchController = searchResultController
        self.searchResultController.searchResultsUpdater = self
        self.searchResultController.searchBar.autocapitalizationType = .none
        self.searchResultController.searchBar.autocorrectionType = .no
    }

    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        
        self.configureSearchResultBar()
        
        self.configureNavigation()
        
        self.localResultController.type = self.type
    }
    
    
    
    // MARK: - Configure UI
    private func configureUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.textLabel)
        self.textLabel.anchor(centerX: self.view,
                         centerY: self.view, paddingCenterY: -100)
    }
}



// MARK: - UISearchResultsUpdating
extension AddLocationController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let vc = searchController.searchResultsController as! LocationResultController
        
        vc.delegate = self
        
        vc.searchTerm = searchController.searchBar.text ?? ""
    }
}




// MARK: - LocationResultControllerDelegate
extension AddLocationController: LocationResultControllerDelegate {
    
    func searchResultLocation(locationString: String) {
        
        self.delegate?.updateLocation(locationString: locationString, type: self.type)
        
        
        // MARK: - BUG
        // 아예 settingController를 나감
//        self.searchResultController.isActive = false
    }
}
