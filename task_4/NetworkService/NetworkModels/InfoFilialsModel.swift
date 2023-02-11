//
//  FilialsModel.swift
//  task_4
//
//  Created by Natalia Drozd on 13.01.23.
//

import Foundation

struct InfoFilialsModel: Codable {
    let filialID, sapID, filialName, nameType: String?
    let name, streetType, street, homeNumber: String?
    let nameTypePrev, namePrev: String?
    let streetTypePrev, streetPrev, homeNumberPrev, infoText: String?
    let infoWorktime, infoBankBik, infoBankUnp, gpsX: String?
    let gpsY, belNumberSchet, foreignNumberSchet, phoneInfo: String?

    enum CodingKeys: String, CodingKey {
        case filialID = "filial_id"
        case sapID = "sap_id"
        case filialName = "filial_name"
        case nameType = "name_type"
        case name
        case streetType = "street_type"
        case street
        case homeNumber = "home_number"
        case nameTypePrev = "name_type_prev"
        case namePrev = "name_prev"
        case streetTypePrev = "street_type_prev"
        case streetPrev = "street_prev"
        case homeNumberPrev = "home_number_prev"
        case infoText = "info_text"
        case infoWorktime = "info_worktime"
        case infoBankBik = "info_bank_bik"
        case infoBankUnp = "info_bank_unp"
        case gpsX = "GPS_X"
        case gpsY = "GPS_Y"
        case belNumberSchet = "bel_number_schet"
        case foreignNumberSchet = "foreign_number_schet"
        case phoneInfo = "phone_info"
    }
}
