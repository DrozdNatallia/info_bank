//
//  ViewControllerPresenter.swift
//  task_4
//
//  Created by Natalia Drozd on 18.01.23.
//

import UIKit
import CoreLocation

protocol HomePresantationLogic {
    func presentData(atm: [InfoAtmModel]?, infobox: [InfoboxModel]?, filials: [InfoFilialsModel]?, userLocation: CLLocationCoordinate2D)
    func presentCurrentData(currentAtm: InfoAtmModel?, currentInfobox: InfoboxModel?, currentFilial: InfoFilialsModel?)
    func presentDataDetailed(currentAtm: InfoAtmModel?, currentInfobox: InfoboxModel?, currentFilial: InfoFilialsModel?, userLocation: CLLocationCoordinate2D?)
    func presentCitiesDictionary(dataArray: [BankInfoModel]) -> [Int: String]
    func presentConvertedData(data: Any)
    func presentAlertError(isNetworkError: Bool, title: String, message: String)
    func presentMarkersData(markers: [Markers])
    func presentFiltredArrayByCity(model: HomeViewControllerModel, section: Int)
}

class HomePresenter {
    
    weak var viewcontroller: HomeDisplayLogic?
    
}
// MARK: Presentation logic
extension HomePresenter: HomePresantationLogic {
    // MARK: Подготовка отфильтрованного массива
    func presentFiltredArrayByCity(model: HomeViewControllerModel, section: Int) {
        var filteredArray = [BankInfoModel]()
        guard let values = model.dictionaryCities[section] else { return }
        filteredArray = model.infoBank.filter({ info in
            info.city == values
        })
        self.viewcontroller?.setFiltredArrayByCity(array: filteredArray)
    }
    
    // MARK: Представление данных из базы данных
    func presentMarkersData(markers: [Markers]) {
        self.viewcontroller?.addMarkersFromDataBase(arrayMarkers: markers)
    }
    // MARK: Представление alert с ошикой
    func presentAlertError(isNetworkError: Bool, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let tryAgainButton = UIAlertAction(title: "Попробовать еще", style: .default) { _ in
            self.viewcontroller?.reloadData()
        }
        let cancelButton = UIAlertAction(title: "Закрыть", style: .cancel)
        let openSetup = UIAlertAction(title: "Открыть настройки", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        if isNetworkError {
            alert.addAction(tryAgainButton)
        } else {
            alert.addAction(openSetup)
        }
        alert.addAction(cancelButton)
        self.viewcontroller?.showAlertError(alert: alert)
    }
    
    // MARK: Представление сконвертированных данных для обновления общего массива при установке фильтров
    func presentConvertedData(data: Any) {
        if let atmsArray = data as? [InfoAtmModel] {
            let convertArray = atmsArray.map { atm -> BankInfoModel in
                let atm = BankInfoModel(installPlace: atm.installPlace, workTime: atm.workTime, currency: atm.currency, gpsX: atm.gpsX, gpsY: atm.gpsY, id: atm.id, city: atm.city, cashIn: atm.cashIn)
                return atm
            }
            self.viewcontroller?.updateInfobank(array: convertArray)
        }
        if let infoboxArray = data as? [InfoboxModel] {
            let convertArray = infoboxArray.map { infobox -> BankInfoModel in
                let infobox = BankInfoModel(installPlace: infobox.installPlace, workTime: infobox.workTime, currency: infobox.currency, gpsX: infobox.gpsX, gpsY: infobox.gpsY, id: String(infobox.infoID ?? 0), city: infobox.city, cashIn: infobox.cashIn)
                return infobox
            }
            self.viewcontroller?.updateInfobank(array: convertArray)
        }
        
        if let filialsArray = data as? [InfoFilialsModel] {
            let convertArray = filialsArray.map { filial in
                let filial = BankInfoModel(installPlace: filial.filialName, workTime: filial.infoWorktime, currency: "", gpsX: filial.gpsX, gpsY: filial.gpsY, id: filial.filialID, city: filial.name, cashIn: "")
                return filial
            }
            self.viewcontroller?.updateInfobank(array: convertArray)
        }
    }
    // MARK: Представление словаря городов с обновленными данными
    func presentCitiesDictionary(dataArray: [BankInfoModel]) -> [Int: String] {
        var citiesArray = [String]()
        for item in dataArray {
            guard let city = item.city else { return [:]}
            citiesArray.append(city)
        }
        let valuesArray = citiesArray.removingDuplicates()
        let keysArray = Array(0...citiesArray.count)
        let dictionaryCities = Dictionary(uniqueKeysWithValues: zip(keysArray, valuesArray))
        self.viewcontroller?.updateDictionaryCities(dictionary: dictionaryCities)
        return dictionaryCities
    }
    
    // MARK: Представление данных для экрана с подробной информацией
    func presentDataDetailed(currentAtm: InfoAtmModel?, currentInfobox: InfoboxModel?, currentFilial: InfoFilialsModel?, userLocation: CLLocationCoordinate2D?) {
        let viewModel = DetailedViewControllerModel(atm: currentAtm, infobox: currentInfobox, filials: currentFilial, userLocation: userLocation)
        self.viewcontroller?.updateDetailedModel(model: viewModel)
    }
    
    // MARK: Представление информации об определенном объекте
    func presentCurrentData(currentAtm: InfoAtmModel?, currentInfobox: InfoboxModel?, currentFilial: InfoFilialsModel?) {
        if let currentAtm = currentAtm {
            let model = InfoViewModel(place: currentAtm.installPlace, id: currentAtm.id, number: "", time: currentAtm.workTime, currency: currentAtm.currency, cashIn: currentAtm.cashIn, gpsX: currentAtm.gpsX, gpsY: currentAtm.gpsY)
            self.viewcontroller?.showInfoWindow(model: model)
        }
        
        if let currentInfobox = currentInfobox {
            let model = InfoViewModel(place: currentInfobox.installPlace, id: String(currentInfobox.infoID ?? 0), number: "", time: currentInfobox.workTime, currency: currentInfobox.currency, cashIn: currentInfobox.cashIn, gpsX: currentInfobox.gpsX, gpsY: currentInfobox.gpsY)
            self.viewcontroller?.showInfoWindow(model: model)
        }
        if let currentFilial = currentFilial {
            let model = InfoViewModel(place: currentFilial.filialName, id: currentFilial.filialID, number: currentFilial.phoneInfo, time: currentFilial.infoWorktime, currency: "", cashIn: "", gpsX: currentFilial.gpsX, gpsY: currentFilial.gpsY)
            self.viewcontroller?.showInfoWindow(model: model)
        }
        
    }
    // MARK: Представление данных для HomeViewController
    func presentData(atm: [InfoAtmModel]?, infobox: [InfoboxModel]?, filials: [InfoFilialsModel]?, userLocation: CLLocationCoordinate2D) {
        var infobank = [BankInfoModel]()
        if let atm = atm {
            let atmModel = atm.map { model -> BankInfoModel in
                let atm = BankInfoModel(installPlace: model.installPlace, workTime: model.workTime, currency: model.currency, gpsX: model.gpsX, gpsY: model.gpsY, id: model.id, city: model.city, cashIn: model.cashIn)
                return atm
            }
            infobank.append(contentsOf: atmModel)
        }
        if let infobox = infobox {
            let boxModel = infobox.map { model -> BankInfoModel in
                let box = BankInfoModel(installPlace: model.installPlace, workTime: model.workTime, currency: model.currency, gpsX: model.gpsX, gpsY: model.gpsY, id: String(model.infoID ?? 0), city: model.city, cashIn: model.cashIn)
                return box
            }
            infobank.append(contentsOf: boxModel)
        }
        if let filials = filials {
            let filialModel = filials.map { model -> BankInfoModel in
                let filial = BankInfoModel(installPlace: model.filialName, workTime: model.infoWorktime, currency: "", gpsX: model.gpsX, gpsY: model.gpsY, id: model.filialID, city: model.name, cashIn: "")
                return filial
            }
            infobank.append(contentsOf: filialModel)
        }
        
        infobank = self.calculateDistance(userLocation: userLocation, arrayData: infobank)
        let sortedArray = infobank.sorted(by: {($0.distance ?? 0) < ($1.distance ?? 0)})
        let dictionaryCities = self.presentCitiesDictionary(dataArray: sortedArray)
        let viewModel = HomeViewControllerModel(atms: atm, infobox: infobox, filials: filials, infoBank: infobank, dictionaryCities: dictionaryCities)
        self.viewcontroller?.displayData(model: viewModel)
        
    }
    // MARK: Вычисление дистанции
    func calculateDistance(userLocation: CLLocationCoordinate2D, arrayData: [BankInfoModel]) -> [BankInfoModel] {
        var infobankArray = arrayData
        let startX = userLocation.longitude
        let startY = userLocation.latitude
        let user = CLLocation(latitude: startY, longitude: startX)
        for (index, value) in infobankArray.enumerated() {
            guard let lat = value.gpsX, let lon = value.gpsY, let gpsX = Double(lat), let gpsY = Double(lon) else { return [] }
            let location = CLLocation(latitude: gpsX, longitude: gpsY)
            let dist = Double(user.distance(from: location))
            infobankArray[index].distance = dist
        }
        return infobankArray
    }
}
