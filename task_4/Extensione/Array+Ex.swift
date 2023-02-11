//
//  Array+Ex.swift
//  task_4
//
//  Created by Natalia Drozd on 14.01.23.
//

import Foundation

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}
