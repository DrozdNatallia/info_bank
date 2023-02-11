//
//  ViewControllerRouter.swift
//  task_4
//
//  Created by Natalia Drozd on 18.01.23.
//

import UIKit

protocol HomeRoutingLogic {
    func navigateToDetailedViewController(model: DetailedViewControllerModel)
    func navigateToFilterViewController()
}

class HomeRouter {
    
    weak var viewcontroller: UIViewController?
    
}

extension HomeRouter: HomeRoutingLogic {
    
    func navigateToDetailedViewController(model: DetailedViewControllerModel) {
        let detailedVC = DetailedViewController()
        detailedVC.router?.dataStore?.data = model
        self.viewcontroller?.navigationController?.pushViewController(detailedVC, animated: true)
    }
    
    func navigateToFilterViewController() {
        let filterVC = FilterViewController()
        self.viewcontroller?.addChild(filterVC)
        filterVC.view.frame = (self.viewcontroller?.view.frame)!
        self.viewcontroller?.view.addSubview(filterVC.view)
        filterVC.didMove(toParent: self.viewcontroller)

    }
}
