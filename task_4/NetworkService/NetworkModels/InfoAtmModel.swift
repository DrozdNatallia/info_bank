//
//  InfoData.swift
//  task_4
//
//  Created by Natalia Drozd on 27.12.22.
//

import UIKit
// MARK: - InfoData

struct InfoAtmModel: Codable {
    let id: String?
    let area: String?
    let cityType: String?
    let city: String?
    let addressType: String?
    let address, house, installPlace, workTime: String?
    let gpsX, gpsY: String?
    let installPlaceFull, workTimeFull: String?
    let atmType: String?
    let atmError: String?
    let currency: String?
    let cashIn, atmPrinter: String?

    enum CodingKeys: String, CodingKey {
        case id, area
        case cityType = "city_type"
        case city
        case addressType = "address_type"
        case address, house
        case installPlace = "install_place"
        case workTime = "work_time"
        case gpsX = "gps_x"
        case gpsY = "gps_y"
        case installPlaceFull = "install_place_full"
        case workTimeFull = "work_time_full"
        case atmType = "ATM_type"
        case atmError = "ATM_error"
        case currency
        case cashIn = "cash_in"
        case atmPrinter = "ATM_printer"
    }
}
