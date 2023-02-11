//
//  DetailedViewController.swift
//  task_4
//
//  Created by Natalia Drozd on 29.12.22.
//

import UIKit
import CoreLocation

protocol DetailedDisplayLogic: AnyObject {
    func displayData(model: DetailedViewControllerModel)
    func openRouteOnMap(url: URL)
    func setArrivleCoordinate(coord: CLLocationCoordinate2D)
    func showAlert(alert: UIAlertController)
}

class DetailedViewController: UIViewController {
    
    private(set) var router: (DetailedRoutingLogic & DetailsDataPassingProtocol)?
    private var interactor: (DetailedBusinessLogic & DetailedStoreProtocol)?
    var detailedModel: DetailedViewControllerModel?
    
    private lazy var buildRouteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Построить маршрут", for: .normal)
        btn.addTarget(self, action: #selector(tappedBuildRouteButton), for: .touchUpInside)
        btn.backgroundColor = .systemTeal
        return btn
    }()
    
    private lazy var infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = lbl.font.withSize(20)
        lbl.textColor = .tintColor
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        return lbl
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.frame = view.bounds
        scroll.contentSize = contentSize
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let content = UIView()
        content.frame.size = contentSize
        return content
    }()
    
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: view.frame.height + 400)
    }
    private var arrivleCoordinate: CLLocationCoordinate2D?
    private var atm: InfoAtmModel?
    private var infobox: InfoboxModel?
    private var filial: InfoFilialsModel?
    private var userLocation: CLLocationCoordinate2D?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    // MARK: Настройка VC
    func setup() {
        let viewcontroller = self
        let interactor = DetailedInteractor()
        let router = DetailedRouter()
        let presenter = DetailedPresenter()
        router.dataStore = interactor
        viewcontroller.interactor = interactor
        viewcontroller.router = router
        presenter.viewcontroller = viewcontroller
        interactor.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.addSubviews()
        self.addConstraints()
        self.interactor?.fetchDetailsData()
    }
    
    private func addSubviews() {
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.buildRouteButton)
        self.scrollView.addSubview(self.contentView)
        self.contentView.addSubview(self.infoLabel)
    }
    
    private func addConstraints() {
        self.infoLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
        self.buildRouteButton.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.1)
            make.top.equalTo(self.scrollView.snp_bottomMargin)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: Заполнение котроллера информацией
    func configured(atm: InfoAtmModel?, infoBox: InfoboxModel?, filial: InfoFilialsModel?, userLocation: CLLocationCoordinate2D?) {
        if let atm = atm {
            guard let cityType = atm.cityType,
                  let city = atm.city,
                  let adrressType = atm.addressType,
                  let adress = atm.address,
                  let house = atm.house,
                  let installPlace = atm.installPlace,
                  let workTime = atm.workTime,
                  let gpsX = atm.gpsX,
                  let gpsY = atm.gpsY,
                  let typeAtm = atm.atmType,
                  let errorAtm = atm.atmError,
                  let currency = atm.currency,
                  let cash = atm.cashIn else { return }
            
            self.infoLabel.text = """
    Адрес:\n\(cityType), \(city), \(adrressType), \(adress), \(house)\n
    Место установки: \n\(installPlace)\n
    Режим работы:\n\(workTime)\n
    Координаты:\n\(gpsX), \(gpsY)\n
    Тип:\n\(typeAtm)\n
    Исправность:\n\(errorAtm)\n
    Валюта:\n\(currency)\n
    Купюроприемник:\n\(cash)
    """
        }
        if let infoBox = infoBox {
            guard let cityType = infoBox.cityType,
                  let city = infoBox.city,
                  let adressType = infoBox.addressType,
                  let address = infoBox.address,
                  let house = infoBox.house,
                  let installPlace = infoBox.installPlace,
                  let workTime = infoBox.workTime,
                  let gpsX = infoBox.gpsX,
                  let gpsY = infoBox.gpsY,
                  let typeInfobox = infoBox.infType,
                  let cashIn = infoBox.cashIn,
                  let typeCashIn = infoBox.typeCashIn,
                  let existCashIn = infoBox.cashInExist,
                  let currency = infoBox.currency,
                  let region = infoBox.regionPlatej,
                  let popolnenie = infoBox.popolneniePlatej,
                  let status = infoBox.infStatus,
                  let id = infoBox.infoID,
                  let printer = infoBox.infPrinter else { return }
            self.infoLabel.text = """
    ID:\n\(id)\n
    Адрес:\n\(cityType), \(city), \(adressType), \(address), \(house)\n
    Место установки: \n\(installPlace)\n
    Режим работы:\n\(workTime)\n
    Координаты:\n\(gpsX), \(gpsY)\n
    Тип:\n\(typeInfobox)\n
    Исправность:\n\(status)\n
    Валюта:\n\(currency)\n
    Купюроприемник:\n\(existCashIn)\n
    Прием пачек банкнот:\n\(typeCashIn)\n
    Исправность купюроприемника:\n\(cashIn)\n
    Печать чека:\n\(printer)\n
    "Региональные платежи":\n\(region)\n
    "Пополнение счета наличными":\n\(popolnenie)
    """
        }
        if let filial = filial {
            guard let id = filial.filialID,
                  let cityType = filial.nameType,
                  let city = filial.name,
                  let adressType = filial.streetType,
                  let address = filial.street,
                  let house = filial.homeNumber,
                  let installPlace = filial.filialName,
                  let workTime = filial.infoWorktime,
                  let gpsX = filial.gpsX,
                  let gpsY = filial.gpsY,
                  let belNumber = filial.belNumberSchet,
                  let foreignNumber = filial.foreignNumberSchet,
                  let phoneNumber = filial.phoneInfo else { return }
            self.infoLabel.text = """
    ID:\n\(id)\n
    Адрес:\n\(cityType), \(city), \(adressType), \(address), \(house)\n
    Место установки: \n\(installPlace)\n
    Режим работы:\n\(workTime)\n
    Координаты:\n\(gpsX), \(gpsY)\n
    Расчетный счет (в белорусских рублях):\n\(belNumber)\n
    Расчетный счет (в иностранной валюте):\n\(foreignNumber)\n
    Номер телефона:\n\(phoneNumber)
    """
        }
    }
    
    // MARK: Построение маршрута по нажатию на кнопку
    @objc func tappedBuildRouteButton() {
        if let atm = self.detailedModel?.atm {
            self.interactor?.getArrivleCoordinate(model: atm)
        }
        if let infobox = self.detailedModel?.infobox {
            self.interactor?.getArrivleCoordinate(model: infobox )
        }
        if let filial = self.detailedModel?.filials {
            self.interactor?.getArrivleCoordinate(model: filial)
        }
        guard let location = self.detailedModel?.userLocation else {
            self.interactor?.getAlert()
            return
        }
        self.interactor?.getRouteUrl(arrivleCoordinate: self.arrivleCoordinate!, userLocation: location)
    }
}

extension DetailedViewController: DetailedDisplayLogic {
    func displayData(model: DetailedViewControllerModel) {
        self.detailedModel = model
        self.configured(atm: model.atm, infoBox: model.infobox, filial: model.filials, userLocation: model.userLocation)
    }
    
    func openRouteOnMap(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func setArrivleCoordinate(coord: CLLocationCoordinate2D) {
        self.arrivleCoordinate = coord
    }
    
    func showAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
}
