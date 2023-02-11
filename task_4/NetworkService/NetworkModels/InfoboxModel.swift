//
//  InfoboxModel.swift
//  task_4
//
//  Created by Natalia Drozd on 10.01.23.
//

import Foundation

// MARK: - InfoboxModel
struct InfoboxModel: Codable {
    let infoID: Int?
    let area: String?
    let cityType: String?
    let city: String?
    let addressType: String?
    let address, house, installPlace, locationNameDesc: String?
    let workTime, timeLong, gpsX, gpsY: String?
    let currency: String?
    let infType: String?
    let cashInExist, cashIn, typeCashIn, infPrinter: String?
    let regionPlatej, popolneniePlatej, infStatus: String?

    enum CodingKeys: String, CodingKey {
        case infoID = "info_id"
        case area
        case cityType = "city_type"
        case city
        case addressType = "address_type"
        case address, house
        case installPlace = "install_place"
        case locationNameDesc = "location_name_desc"
        case workTime = "work_time"
        case timeLong = "time_long"
        case gpsX = "gps_x"
        case gpsY = "gps_y"
        case currency
        case infType = "inf_type"
        case cashInExist = "cash_in_exist"
        case cashIn = "cash_in"
        case typeCashIn = "type_cash_in"
        case infPrinter = "inf_printer"
        case regionPlatej = "region_platej"
        case popolneniePlatej = "popolnenie_platej"
        case infStatus = "inf_status"
    }
}
