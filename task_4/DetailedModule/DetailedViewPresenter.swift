//
//  DetailedViewPresenter.swift
//  task_4
//
//  Created by Natalia Drozd on 21.01.23.
//

import Foundation
import UIKit
import CoreLocation

protocol DetailedPresentationLogic {
    func presentDetailedInfo(atm: InfoAtmModel?, infobox: InfoboxModel?, filial: InfoFilialsModel?, location: CLLocationCoordinate2D?)
    func presentUrl(url: String)
    func presenterArrivleCoordinate(latitude: String, longitude: String)
    func presentAlertMessage()
}

class DetailedPresenter {
    weak var viewcontroller: DetailedDisplayLogic?
}

extension DetailedPresenter: DetailedPresentationLogic {
    // MARK: Представление alert
    func presentAlertMessage() {
        let alert = UIAlertController(title: "Нет доступа к геолокации", message: "", preferredStyle: .alert)
        let openSetup = UIAlertAction(title: "Открыть настройки", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        let cancel = UIAlertAction(title: "Закрыть", style: .cancel)
        alert.addAction(openSetup)
        alert.addAction(cancel)
        self.viewcontroller?.showAlert(alert: alert)
    }
    // MARK: Представление подробной информации
    func presentDetailedInfo(atm: InfoAtmModel?, infobox: InfoboxModel?, filial: InfoFilialsModel?, location: CLLocationCoordinate2D?) {
        let viewModel = DetailedViewControllerModel(atm: atm, infobox: infobox, filials: filial, userLocation: location)
        self.viewcontroller?.displayData(model: viewModel)
    }
    // MARK: Представление конечных координат
    func presenterArrivleCoordinate(latitude: String, longitude: String) {
        guard let lat = Double(latitude), let long = Double(longitude) else {
            return
        }
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.viewcontroller?.setArrivleCoordinate(coord: coord)
        
    }
    // MARK: Представление url маршрута
    func presentUrl(url: String) {
        guard let url = URL(string: url) else { return }
        self.viewcontroller?.openRouteOnMap(url: url)
    }
}
