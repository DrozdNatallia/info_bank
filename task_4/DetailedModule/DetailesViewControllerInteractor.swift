//
//  DetailesViewControllerInteractor.swift
//  task_4
//
//  Created by Natalia Drozd on 18.01.23.
//

import UIKit
import CoreLocation

protocol DetailedBusinessLogic {
    func fetchDetailsData()
    func getRouteUrl(arrivleCoordinate: CLLocationCoordinate2D, userLocation: CLLocationCoordinate2D)
    func getArrivleCoordinate(model: Any)
    func getAlert()
}

protocol DetailedStoreProtocol: AnyObject {
    var data: DetailedViewControllerModel {get set}
}

class DetailedInteractor: DetailedStoreProtocol {
    var presenter: DetailedPresentationLogic?
    var data = DetailedViewControllerModel(atm: nil, infobox: nil, filials: nil, userLocation: nil)
    
}

extension DetailedInteractor: DetailedBusinessLogic {
    // MARK: Получение alert с ошибкой
    func getAlert() {
        self.presenter?.presentAlertMessage()
    }
    // MARK: Загрузка данных
    func fetchDetailsData() {
        self.presenter?.presentDetailedInfo(atm: data.atm, infobox: data.infobox, filial: data.filials, location: data.userLocation)
        
    }
    // MARK: Получение конечных координат
    func getArrivleCoordinate(model: Any) {
        if let atm = model as? InfoAtmModel {
            guard let lat = atm.gpsX, let lon = atm.gpsY else { return }
            self.presenter?.presenterArrivleCoordinate(latitude: lat, longitude: lon)
        }
        if let infobox = model as? InfoboxModel {
            guard let lat = infobox.gpsX, let lon = infobox.gpsY else { return }
            self.presenter?.presenterArrivleCoordinate(latitude: lat, longitude: lon)
        }
        
        if let filial = model as? InfoFilialsModel {
            guard let lat = filial.gpsX, let lon = filial.gpsY else { return }
            self.presenter?.presenterArrivleCoordinate(latitude: lat, longitude: lon)
        }
    }
    // MARK: Получение url маршрута
    func getRouteUrl(arrivleCoordinate: CLLocationCoordinate2D, userLocation: CLLocationCoordinate2D) {
        
        let arrivalat = String(arrivleCoordinate.latitude)
        let arrivalLon = String(arrivleCoordinate.longitude)
        let userLat = String(userLocation.latitude)
        let userLon = String(userLocation.longitude)
        
        if let url = URL(string: Constants.baseGoogleUrl), UIApplication.shared.canOpenURL(url) {
            let str = Constants
                .baseGoogleUrl
                .appending("saddr=\(userLat),\(userLon)&daddr=\(arrivalat),\(arrivalLon)&directionsmode=driving")
            self.presenter?.presentUrl(url: str)
        } else if let url = URL(string: Constants.baseYandexUrl), UIApplication.shared.canOpenURL(url) {
            let str = Constants
                .baseYandexUrl
                .appending("rtext=\(userLat),\(userLon)~\(arrivalat),\(arrivalLon)&rtt=auto")
            self.presenter?.presentUrl(url: str)
        } else if let url = URL(string: Constants.baseMapKitUrl), UIApplication.shared.canOpenURL(url) {
            let str = Constants
                .baseMapKitUrl
                .appending("saddr=\(userLat),\(userLon)&daddr=\(arrivalat),\(arrivalLon)&dirflg=d")
            self.presenter?.presentUrl(url: str)
        } else {
            print("error")
        }
    }
}
