//
//  TypeInfoBank.swift
//  task_4
//
//  Created by Natalia Drozd on 14.01.23.
//

import Foundation

enum TypeInfoBank: Int {
    case atm = 0
    case infobox = 1
    case filials = 2
    
    var description: String {
        switch self {
        case .atm:
            return "atm"
        case .infobox:
            return "infobox"
        case .filials:
            return "filials"
        }
    }
}
