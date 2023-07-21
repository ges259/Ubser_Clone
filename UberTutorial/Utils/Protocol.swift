//
//  Protocol.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

//import Foundation

protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

protocol LocationInputViewDelegate: AnyObject {
    func dismissLocationInputView()
    func executeSearch(query: String)
}


