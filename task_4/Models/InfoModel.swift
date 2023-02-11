//
//  InfoAtmModel.swift
//  task_4
//
//  Created by Natalia Drozd on 3.01.23.
//

import Foundation
import CoreLocation

// MARK: Хранит информацию о всех данных, полученных из запросов
struct InfoModel {
    var atms: [InfoAtmModel]?
    var infobox: [InfoboxModel]?
    var filials: [InfoFilialsModel]?
}
