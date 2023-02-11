//
//  DetailedViewControllerRouter.swift
//  task_4
//
//  Created by Natalia Drozd on 18.01.23.
//

import UIKit

protocol DetailedRoutingLogic {
    
}

protocol DetailsDataPassingProtocol {
    var dataStore: DetailedStoreProtocol? { get }
    
}
class DetailedRouter: DetailsDataPassingProtocol {
    
    weak var dataStore: DetailedStoreProtocol?
    
}

extension DetailedRouter: DetailedRoutingLogic {
    
}
