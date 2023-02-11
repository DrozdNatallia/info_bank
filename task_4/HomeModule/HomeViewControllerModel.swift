//
//  HomeViewControllerModel.swift
//  task_4
//
//  Created by Natalia Drozd on 22.01.23.
//

import Foundation

struct HomeViewControllerModel {
    var atms: [InfoAtmModel]?
    var infobox: [InfoboxModel]?
    var filials: [InfoFilialsModel]?
    var infoBank = [BankInfoModel]()
    var dictionaryCities = [Int: String]()
    var filteredInfoBankByCity: [BankInfoModel] = []
}
