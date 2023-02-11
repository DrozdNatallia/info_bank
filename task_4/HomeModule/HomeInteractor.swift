//
//  ViewControllerInteractor.swift
//  task_4
//
//  Created by Natalia Drozd on 18.01.23.
//

import UIKit
import CoreLocation

protocol HomeBusinessLogic {
    func fetchData(userLocation: CLLocationCoordinate2D)
    func getCurrentPlace(gpsX: Double, gpsY: Double, userLocation: CLLocationCoordinate2D?, isOpenDetailedVc: Bool)
    func reloadData(atm: Bool, infobox: Bool, filials: Bool, userLocation: CLLocationCoordinate2D)
    func reloadCitiesDictionary(arrayData: [BankInfoModel])
    func getConvertedDate(data: Any)
    func getAlert(isNetwork: Bool, title: String, message: String)
    func setValueUserDefault()
    func saveMarkersToDatabase(name: String, latitude: Double, longitude: Double)
    func filterArrayByCity(model: HomeViewControllerModel, section: Int)
    func fetchMarkersFromDatabase()
    
}

class HomeInteractor {
    
    var presenter: HomePresantationLogic?
    var networkProvaider: NetworkProvaiderProtocol?
    var infoModel: InfoModel?
    
}

extension HomeInteractor: HomeBusinessLogic {
    // MARK: Фильтрация общего массива по названию города
    func filterArrayByCity(model: HomeViewControllerModel, section: Int) {
        self.presenter?.presentFiltredArrayByCity(model: model, section: section)
    }
    // MARK: Установка значений UserDefault при первом запуске
    func setValueUserDefault() {
        UserDefaults.standard.set(true, forKey: TypeInfoBank.atm.description)
        UserDefaults.standard.set(true, forKey: TypeInfoBank.infobox.description)
        UserDefaults.standard.set(true, forKey: TypeInfoBank.filials.description)
    }
    
    // MARK: Сохранение маркеров в базу данных
    func saveMarkersToDatabase(name: String, latitude: Double, longitude: Double) {
        let markers = DataManager.shared.getMarkers()
        let marker = markers.first { mark in
            mark.latitude == latitude && mark.longitude == longitude
        }
        if marker == nil {
            DataManager.shared.setMarkers(name: name, latitude: latitude, longitude: longitude)
            DataManager.shared.save()
        }
    }
    
    // MARK: Загрузка маркеров из базы данных
    func fetchMarkersFromDatabase() {
        let markers = DataManager.shared.getMarkers()
        self.presenter?.presentMarkersData(markers: markers)
        
    }
    // MARK: Обработка ошибок
    func getAlert(isNetwork: Bool, title: String, message: String) {
        self.presenter?.presentAlertError(isNetworkError: isNetwork, title: title, message: message)
    }
    // MARK: Конвертирование данных для обновления общего массива, при установке фильтров
    func getConvertedDate(data: Any) {
        if let atm = data as? [InfoAtmModel] {
            self.presenter?.presentConvertedData(data: atm)
        }
        if let infobox = data as? [InfoboxModel] {
            self.presenter?.presentConvertedData(data: infobox)
        }
        
        if let filial = data as? [InfoFilialsModel] {
            self.presenter?.presentConvertedData(data: filial)
        }
    }
    // MARK: Обновление словаря со списком городов
    func reloadCitiesDictionary(arrayData: [BankInfoModel]) {
        _ = self.presenter?.presentCitiesDictionary(dataArray: arrayData)
    }
    // MARK: Получение по ID определенного объекта, использую при открытии экрана с подробной информацией, и при нажатии на ячейку коллекции
    func getCurrentPlace(gpsX: Double, gpsY: Double, userLocation: CLLocationCoordinate2D?, isOpenDetailedVc: Bool) {
        if let atmCurrent = self.infoModel?.atms?.first(where: { model in
            Double(model.gpsX ?? "0") == gpsX && Double(model.gpsY ?? "0") == gpsY
        }) {
            if isOpenDetailedVc {
                self.presenter?.presentDataDetailed(currentAtm: atmCurrent, currentInfobox: nil, currentFilial: nil, userLocation: userLocation)
            } else {
                self.presenter?.presentCurrentData(currentAtm: atmCurrent, currentInfobox: nil, currentFilial: nil)
            }
        }
        
        if let infoboxCurrent = self.infoModel?.infobox?.first(where: { model in
            Double(model.gpsX ?? "0") == gpsX && Double(model.gpsY ?? "0") == gpsY
        }) {
            if isOpenDetailedVc {
                self.presenter?.presentDataDetailed(currentAtm: nil, currentInfobox: infoboxCurrent, currentFilial: nil, userLocation: userLocation)
            } else {
                self.presenter?.presentCurrentData(currentAtm: nil, currentInfobox: infoboxCurrent, currentFilial: nil)
            }
        }
        
        if let filialsCurrent = self.infoModel?.filials?.first(where: { model in
            Double(model.gpsX ?? "0") == gpsX && Double(model.gpsY ?? "0") == gpsY
        }) {
            if isOpenDetailedVc {
                self.presenter?.presentDataDetailed(currentAtm: nil, currentInfobox: nil, currentFilial: filialsCurrent, userLocation: userLocation)
            } else {
                self.presenter?.presentCurrentData(currentAtm: nil, currentInfobox: nil, currentFilial: filialsCurrent)
            }
        }
        
    }
    // MARK: Обновление данных при нажатии на кнопку обновить
    func reloadData(atm: Bool, infobox: Bool, filials: Bool, userLocation: CLLocationCoordinate2D ) {
        if !Reachability().isConnectedToNetwork() {
            self.fetchMarkersFromDatabase()
            self.presenter?.presentAlertError(isNetworkError: true, title: "Приложение не работает без интернета", message: "")
            return
        }
        if atm {
            self.networkProvaider?.getAtmFromURL { [weak self] info in
                guard let self = self, let info = info else { return }
                self.infoModel?.atms = info
                DispatchQueue.main.async {
                    self.presenter?.presentData(atm: info, infobox: nil, filials: nil, userLocation: userLocation)
                }
            }
        }
        
        let queue = DispatchQueue.global(qos: .utility)
        if infobox {
            queue.async {
                self.networkProvaider?.getInfoboxFromUrl { [weak self] info in
                    guard let self = self, let info = info else { return }
                    self.infoModel?.infobox = info
                    DispatchQueue.main.async {
                        self.presenter?.presentData(atm: nil, infobox: self.infoModel?.infobox, filials: nil, userLocation: userLocation)
                    }
                }
            }
        }
        if filials {
            queue.async {
                self.networkProvaider?.getFilialsFromUrl { [weak self] info in
                    guard let self = self, let info = info else {
                        return
                    }
                    self.infoModel?.filials = info
                    DispatchQueue.main.async {
                        self.presenter?.presentData(atm: nil, infobox: nil, filials: self.infoModel?.filials, userLocation: userLocation)
                    }
                }
            }
        }
    }
    // MARK: Получение сообщения с ошибкой, если нет каких-то данных
    private func getErrorMessage() -> String? {
        var message = "Нет доступа к данным: "
        if self.infoModel?.atms == nil {
            message += "банкоматы "
        }
        if self.infoModel?.infobox == nil {
            message += "инфокиоски "
        }
        if self.infoModel?.filials == nil {
            message += "филиалы"
        }
        if self.infoModel?.atms == nil || self.infoModel?.infobox == nil || self.infoModel?.filials == nil {
            return message
        }
        return nil
    }
    // MARK: Загрузка данных из сети ( при загрузке приложения)
    func fetchData(userLocation: CLLocationCoordinate2D) {
        if !Reachability().isConnectedToNetwork() {
            self.fetchMarkersFromDatabase()
            self.presenter?.presentAlertError(isNetworkError: true, title: "Приложение не работает без интернета", message: "")
            return
        }
        
        let group = DispatchGroup()
        group.enter()
        self.networkProvaider?.getAtmFromURL { [weak self] info in
            guard let self = self else { return }
            self.infoModel?.atms = info
            group.leave()
        }
        group.enter()
        self.networkProvaider?.getInfoboxFromUrl { [weak self] info in
            guard let self = self else { return }
            self.infoModel?.infobox = info
            group.leave()
        }
        group.enter()
        self.networkProvaider?.getFilialsFromUrl { [weak self] info in
            guard let self = self else { return }
            self.infoModel?.filials = info
            group.leave()
        }
        group.notify(queue: .main) {
            if let message = self.getErrorMessage() {
                self.presenter?.presentAlertError(isNetworkError: true, title: "Ошибка сети", message: message)
            }
            self.presenter?.presentData(atm: self.infoModel?.atms, infobox: self.infoModel?.infobox, filials: self.infoModel?.filials, userLocation: userLocation)
        }
    }
}
