//
//  FilterInteractor.swift
//  task_4
//
//  Created by Natalia Drozd on 22.01.23.
//

import UIKit

protocol FilterBusinessLogic {
    func postMessageToNotification(name: String)
}

class FilterInteractor {
    
}

extension FilterInteractor: FilterBusinessLogic {
    
    func postMessageToNotification(name: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil)
    }
}
