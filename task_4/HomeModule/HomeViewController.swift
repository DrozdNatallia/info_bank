//
//  ViewController.swift
//  task_4
//
//  Created by Natalia Drozd on 27.12.22.
//

import UIKit
import SnapKit
import GoogleMaps
import CoreLocation
import SystemConfiguration
import CoreData

protocol HomeDisplayLogic: AnyObject {
    func displayData(model: HomeViewControllerModel)
    func showInfoWindow(model: InfoViewModel)
    func updateDetailedModel(model: DetailedViewControllerModel)
    func updateDictionaryCities(dictionary: [Int: String])
    func updateInfobank(array: [BankInfoModel])
    func showAlertError(alert: UIAlertController)
    func reloadData()
    func addMarkersFromDataBase(arrayMarkers: [Markers])
    func setFiltredArrayByCity(array: [BankInfoModel])
}
class HomeViewController: UIViewController {
    private(set) var router: HomeRoutingLogic?
    private var interactor: HomeBusinessLogic?
    
    var viewModel = HomeViewControllerModel()
    var infoViewModel = InfoViewModel()
    
    private lazy var coreManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    private lazy var updateButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "Обновить", style: .plain, target: self, action: #selector(onUpdateButton))
        btn.isEnabled = false
        btn.tintColor = .tintColor
        return btn
    }()
    
    private lazy var filterButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "Фильтр", style: .plain, target: self, action: #selector(onFilterButton))
        btn.isEnabled = false
        btn.tintColor = .tintColor
        return btn
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Карта", "Список"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.cornerRadius = 5.0
        segmentedControl.backgroundColor = .systemGray4
        segmentedControl.tintColor = .tintColor
        segmentedControl.addTarget(self, action: #selector(segmentedTapped), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: 53.9, longitude: 27.56, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        return mapView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)
        var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.reuseIdentificator)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.isHidden = true
        return collectionView
    }()
    
    private lazy var infoView: CustomInfoView = {
        let window = CustomInfoView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        window.detailedButton.addTarget(self, action: #selector(tappedDetailedButton), for: .touchUpInside)
        return window
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = self.view.bounds
        return blur
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activity.color = .darkGray
        activity.center = self.view.center
        activity.hidesWhenStopped = true
        activity.startAnimating()
        return activity
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coreManager.requestWhenInUseAuthorization()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.setRightBarButton(self.updateButton, animated: true)
        self.navigationItem.setRightBarButton(self.filterButton, animated: true)
        self.navigationItem.setRightBarButtonItems([self.filterButton, self.updateButton], animated: true)
        self.addSubviews()
        self.addConstraints()
        self.addListeners()
        self.setup()
        self.interactor?.setValueUserDefault()
    }
    
    override func viewWillLayoutSubviews() {
        self.collectionView.collectionViewLayout.invalidateLayout()
        if self.view.frame.height < 500 {
            self.infoView.center.x += 150
        } else {
            self.infoView.center.y -= 150
        }
    }
    // MARK: Настройка vc
    func setup() {
        let viewcontroller = self
        let presenter = HomePresenter()
        let interactor = HomeInteractor()
        let router = HomeRouter()
        let provaider = NetworkProvaider()
        let infoModel = InfoModel()
        interactor.infoModel = infoModel
        interactor.presenter = presenter
        presenter.viewcontroller = viewcontroller
        viewcontroller.interactor = interactor
        viewcontroller.router = router
        interactor.networkProvaider = provaider
        router.viewcontroller = viewcontroller
    }
    
    // MARK: Обновление контента после получения ответов
    private func updateUI() {
        self.updateButton.isEnabled = true
        self.filterButton.isEnabled = true
        self.collectionView.reloadData()
        self.blurView.removeFromSuperview()
        self.activityIndicator.removeFromSuperview()
    }
    
    // MARK: Добавление меток с банкоматами на карту
    private func addAtmMarkerToMap() {
        guard let atms = self.viewModel.atms else { return }
        for bancomat in atms {
            guard let gpsX = bancomat.gpsX,
                  let lan = Double(gpsX),
                  let gpsY = bancomat.gpsY,
                  let lon = Double(gpsY) else { return }
            self.interactor?.saveMarkersToDatabase(name: TypeInfoBank.atm.description, latitude: lan, longitude: lon)
            self.addMarkers(type: TypeInfoBank.atm.description, lantitude: lan, longitude: lon)
        }
    }
    // MARK: Добавление меток инфокисков
    private func addInfoboxMarkerToMap() {
        guard let infoboxes = self.viewModel.infobox else { return }
        for infobox in infoboxes {
            guard let gpsX = infobox.gpsX,
                  let lan = Double(gpsX),
                  let gpsY = infobox.gpsY,
                  let lon = Double(gpsY) else { return }
            self.interactor?.saveMarkersToDatabase(name: TypeInfoBank.infobox.description, latitude: lan, longitude: lon)
            self.addMarkers(type: TypeInfoBank.infobox.description, lantitude: lan, longitude: lon)
        }
    }
    // MARK: Добавление меток филиалов
    private func addFilialsMarkerToMap() {
        guard let filials = self.viewModel.filials else { return }
        for filial in filials {
            guard let gpsX = filial.gpsX,
                  let lan = Double(gpsX),
                  let gpsY = filial.gpsY,
                  let lon = Double(gpsY) else { return }
            self.interactor?.saveMarkersToDatabase(name: TypeInfoBank.filials.description, latitude: lan, longitude: lon)
            self.addMarkers(type: TypeInfoBank.filials.description, lantitude: lan, longitude: lon)
        }
    }
    
    // MARK: Добавление меток
    private func addMarkers(type: String, lantitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: lantitude, longitude: longitude)
        let marker = GMSMarker()
        marker.icon = UIImage(named: type.description)
        marker.position = location
        marker.map = self.mapView
    }
    
    // MARK: Обновление по нажатию на кнопку
    @objc func onUpdateButton(sender: UIBarButtonItem!) {
        self.viewModel = HomeViewControllerModel()
        let atms = UserDefaults.standard.bool(forKey: TypeInfoBank.atm.description)
        let infobox = UserDefaults.standard.bool(forKey: TypeInfoBank.infobox.description)
        let filials = UserDefaults.standard.bool(forKey: TypeInfoBank.filials.description)
        self.updateButton.isEnabled = false
        self.filterButton.isEnabled = false
        if atms {
            self.view.addSubview(self.blurView)
            self.view.addSubview(self.activityIndicator)
        }
        let lat = coreManager.location?.coordinate.latitude ?? 31.015039
        let lon = coreManager.location?.coordinate.longitude ?? 52.425163
        self.interactor?.reloadData(atm: atms, infobox: infobox, filials: filials, userLocation: CLLocationCoordinate2D(latitude: lat, longitude: lon))
    }
    
    // MARK: Открытие окна с настройкой фильтров
    @objc func onFilterButton(sender: UIBarButtonItem) {
        self.router?.navigateToFilterViewController()
    }
    
    // MARK: Обновление контента при установке фильтров
    @objc func setFilter() {
        self.mapView.clear()
        self.viewModel.infoBank.removeAll()
        if UserDefaults.standard.bool(forKey: TypeInfoBank.atm.description) {
            self.addAtmMarkerToMap()
            guard let atms = self.viewModel.atms else { return }
            self.interactor?.getConvertedDate(data: atms)
        }
        if UserDefaults.standard.bool(forKey: TypeInfoBank.infobox.description) {
            self.addInfoboxMarkerToMap()
            guard let infobox = self.viewModel.infobox else { return }
            self.interactor?.getConvertedDate(data: infobox)
        }
        if UserDefaults.standard.bool(forKey: TypeInfoBank.filials.description) {
            self.addFilialsMarkerToMap()
            guard let filial = self.viewModel.filials else { return }
            self.interactor?.getConvertedDate(data: filial)
        }
        self.interactor?.reloadCitiesDictionary(arrayData: self.viewModel.infoBank)
        self.collectionView.reloadData()
    }
    
    func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(setFilter), name: NSNotification.Name(rawValue: TypeInfoBank.atm.description), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setFilter), name: NSNotification.Name(rawValue: TypeInfoBank.infobox.description), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setFilter), name: NSNotification.Name(rawValue: TypeInfoBank.filials.description), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: Переход на DetailedVC по нажатию на кнопку
    @objc func tappedDetailedButton() {
        guard let gpsX = self.infoView.getCoordinate()[0], let gpsY = self.infoView.getCoordinate()[1] else { return }
        self.interactor?.getCurrentPlace(gpsX: Double(gpsX) ?? 0, gpsY: Double(gpsY) ?? 0, userLocation: self.coreManager.location?.coordinate, isOpenDetailedVc: true)
    }
    
    // MARK: Переключение между экранами SegmentedControl
    @objc func segmentedTapped(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.mapView.isHidden = false
            self.collectionView.isHidden = true
        default:
            mapView.isHidden = true
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Добавление subviews
    private func addSubviews() {
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.blurView)
        self.view.addSubview(self.activityIndicator)
    }
    
    // MARK: Настройка констрейнтов
    private func addConstraints() {
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp_topMargin).multipliedBy(0.9)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.05)
        }
        self.mapView.snp.makeConstraints { make in
            make.top.equalTo(self.segmentedControl.snp_bottomMargin).offset(15)
            make.left.right.bottom.equalToSuperview()
        }
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.segmentedControl.snp_bottomMargin).offset(15)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: UICOLLECTIONVIEWDATASOURCE
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.viewModel.dictionaryCities.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.interactor?.filterArrayByCity(model: self.viewModel, section: section)
        return self.viewModel.filteredInfoBankByCity.count
    }
    
    // MARK: заполнение ячеек
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseIdentificator, for: indexPath) as? CollectionViewCell {
            self.interactor?.filterArrayByCity(model: self.viewModel, section: indexPath.section)
            let filteredArray = self.viewModel.filteredInfoBankByCity
            if indexPath.row >= filteredArray.count { return UICollectionViewCell()}
            guard let place = filteredArray[indexPath.row].installPlace,
                  let time = filteredArray[indexPath.row].workTime,
                  let currency = filteredArray[indexPath.row].currency,
                  let id = filteredArray[indexPath.row].id,
                  let gpsX = filteredArray[indexPath.row].gpsX,
                  let gpsY = filteredArray[indexPath.row].gpsY else {
                return UICollectionViewCell()
            }
            cell.backgroundColor = .systemTeal
            cell.configured(place: place, time: time, currency: currency, id: id, gpsX: gpsX, gpsY: gpsY)
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: заполнение header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeader.reuseId,
                for: indexPath) as? SectionHeader {
                guard indexPath.section < self.viewModel.dictionaryCities.count, let city = self.viewModel.dictionaryCities[indexPath.section] else { return UICollectionReusableView() }
                sectionHeader.configured(nameCity: city)
                return sectionHeader
            }
        }
        return UICollectionReusableView()
    }
}

// MARK: UICOLLECTIONVIEWDELEGATE
extension HomeViewController: UICollectionViewDelegate {
    // MARK: нажатие на ячкейку
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.segmentedControl.selectedSegmentIndex = 0
        self.collectionView.isHidden = true
        self.mapView.isHidden = false
        
        let index = IndexPath(item: indexPath.row, section: indexPath.section)
        if let cell = collectionView.cellForItem(at: index) as? CollectionViewCell {
            guard let gpsX = cell.getCoordinate()[0], let gpsY = cell.getCoordinate()[1] else { return }
            
            self.interactor?.getCurrentPlace(gpsX: Double(gpsX) ?? 0, gpsY: Double(gpsY) ?? 0, userLocation: nil, isOpenDetailedVc: false)
            let current = infoViewModel
            guard let place = current.place,
                  let id = current.id,
                  let cashIn = current.cashIn,
                  let time = current.time,
                  let number = current.number,
                  let currency = current.currency,
                  let gpsX = current.gpsX,
                  let gpsY = current.gpsY,
                  let positionX = Double(gpsX),
                  let positionY = Double(gpsY) else { return }
            if number == "" {
                self.infoView.configured(place: place, currency: currency, time: time, cashIn: cashIn, id: id, gpsX: gpsX, gpsY: gpsY)
            } else {
                self.infoView.configuredFilialsCell(place: place, time: time, number: number, filialId: id, gpsX: gpsX, gpsY: gpsY)
            }
            
            self.mapView.camera = GMSCameraPosition.camera(withLatitude: positionX, longitude: positionY, zoom: 6.0)
            self.infoView.center = self.mapView.projection.point(for: CLLocationCoordinate2D(latitude: positionX, longitude: positionY))
            self.mapView.addSubview(self.infoView)
            
            if self.view.frame.height < 500 {
                self.infoView.center.x += 130
            } else {
                self.infoView.center.y -= 130
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: размервы и расстояния между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 40) / 3, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 64)
    }
}

// MARK: GMSMAPVIEWDELEGATE
extension HomeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // MARK: открытие customInfoWindow
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if Reachability().isConnectedToNetwork() {
            self.interactor?.getCurrentPlace(gpsX: marker.position.latitude, gpsY: marker.position.longitude, userLocation: nil, isOpenDetailedVc: false)
            let current = self.infoViewModel
            guard let place = current.place,
                  let id = current.id,
                  let cashIn = current.cashIn,
                  let time = current.time,
                  let number = current.number,
                  let currency = current.currency,
                  let gpsX = current.gpsX,
                  let gpsY = current.gpsY else { return true}
            if number == "" {
                self.infoView.configured(place: place, currency: currency, time: time, cashIn: cashIn, id: id, gpsX: gpsX, gpsY: gpsY)
            } else {
                self.infoView.configuredFilialsCell(place: place, time: time, number: number, filialId: id, gpsX: gpsX, gpsY: gpsY)
            }
            self.mapView.addSubview(self.infoView)
        }
        return false
    }
    
    // MARK: положение infoWindow на карте
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let location = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
        self.infoView.center = mapView.projection.point(for: location)
        if self.view.frame.height < 500 {
            self.infoView.center.x += 130
        } else {
            self.infoView.center.y -= 130
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.infoView.removeFromSuperview()
    }
}

// MARK: CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            self.coreManager.startUpdatingLocation()
            guard let location = manager.location else { return }
            self.interactor?.fetchData(userLocation: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        } else if manager.authorizationStatus == .restricted || manager.authorizationStatus == .denied {
            self.coreManager.stopUpdatingLocation()
            self.interactor?.fetchData(userLocation: CLLocationCoordinate2D(latitude: 31.015039, longitude: 52.425163))
            self.interactor?.getAlert(isNetwork: false, title: "Нет доступа к геолокации", message: "")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationSafe = locations.last {
            self.coreManager.stopUpdatingLocation()
            let latitude = locationSafe.coordinate.latitude
            let longitude = locationSafe.coordinate.longitude
            self.mapView.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 15.0)
        }
    }
}

extension HomeViewController: HomeDisplayLogic {
    func displayData(model: HomeViewControllerModel) {
        var newViewModel = model
        if model.atms == nil {
            newViewModel.atms = self.viewModel.atms
        }
        if model.infobox == nil {
            newViewModel.infobox = self.viewModel.infobox
        }
        if model.filials == nil {
            newViewModel.filials = self.viewModel.filials
        }
        self.viewModel = newViewModel
        self.addAtmMarkerToMap()
        self.addInfoboxMarkerToMap()
        self.addFilialsMarkerToMap()
        self.collectionView.reloadData()
        self.updateUI()
    }
    
    func showInfoWindow(model: InfoViewModel) {
        self.infoViewModel = model
    }
    
    func updateDetailedModel(model: DetailedViewControllerModel) {
        self.router?.navigateToDetailedViewController(model: model)
    }
    
    func updateDictionaryCities(dictionary: [Int: String]) {
        self.viewModel.dictionaryCities = dictionary
    }
    
    func updateInfobank(array: [BankInfoModel]) {
        self.viewModel.infoBank.append(contentsOf: array)
    }

    func showAlertError(alert: UIAlertController) {
        self.present(alert, animated: true)
        self.blurView.removeFromSuperview()
        self.activityIndicator.removeFromSuperview()
        self.updateButton.isEnabled = true
        self.filterButton.isEnabled = true
    }
    
    func reloadData() {
        let lat = coreManager.location?.coordinate.latitude ?? 31.015039
        let lon = coreManager.location?.coordinate.longitude ?? 52.425163
        interactor?.fetchData(userLocation: CLLocationCoordinate2D(latitude: lat, longitude: lon))
    }
    
    func addMarkersFromDataBase(arrayMarkers: [Markers]) {
        let markers = arrayMarkers
        for marker in markers {
            guard let type = marker.name else { return }
            self.addMarkers(type: type, lantitude: marker.latitude, longitude: marker.longitude)
        }
    }
    
    func setFiltredArrayByCity(array: [BankInfoModel]) {
        self.viewModel.filteredInfoBankByCity = array
    }
}
