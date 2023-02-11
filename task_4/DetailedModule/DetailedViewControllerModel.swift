//
//  DetailedViewControllerModel.swift
//  task_4
//
//  Created by Natalia Drozd on 22.01.23.
//

import Foundation
import CoreLocation

struct DetailedViewControllerModel {
    let atm: InfoAtmModel?
    let infobox: InfoboxModel?
    let filials: InfoFilialsModel?
    let userLocation: CLLocationCoordinate2D?
}
