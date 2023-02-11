//
//  CustomInfoWindow.swift
//  task_4
//
//  Created by Natalia Drozd on 2.01.23.
//

import UIKit

class CustomInfoView: UIView {
    private lazy var place: BaseLabel = {
        let lbl = BaseLabel()
        return lbl
    }()
    
    private lazy var workTime: BaseLabel = {
        let lbl = BaseLabel()
        return lbl
    }()
    
    private lazy var currency: BaseLabel = {
        let lbl = BaseLabel()
        return lbl
    }()
    
    private lazy var cashIn: BaseLabel = {
        let lbl = BaseLabel()
        return lbl
    }()
    
    private lazy var placeTitle: BaseLabel = {
        let lbl = BaseLabel()
        lbl.text = "Место установки:"
        return lbl
    }()
    
    private lazy var workTimeTitle: BaseLabel = {
        let lbl = BaseLabel()
        lbl.font = lbl.font.withSize(15)
        lbl.text = "Режим работы:"
        return lbl
    }()
    
    private lazy var currencyTitle: BaseLabel = {
        let lbl = BaseLabel()
        lbl.font = lbl.font.withSize(15)
        lbl.text = "Валюта:"
        return lbl
    }()
    
    private lazy var cashInTitle: UILabel = {
        let lbl = BaseLabel()
        lbl.font = lbl.font.withSize(15)
        lbl.text = "Прием наличных:"
        return lbl
    }()
    
    lazy var detailedButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Подробнее", for: .normal)
        btn.backgroundColor = .systemTeal
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.cgColor
        return btn
    }()
    
    private lazy var stackViewPlace: BaseStackView = {
        let stack = BaseStackView()
        return stack
    }()
    
    private lazy var stackViewTime: BaseStackView = {
        let stack = BaseStackView()
        return stack
    }()
    
    private lazy var stackViewCurrency: BaseStackView = {
        let stack = BaseStackView()
        return stack
    }()
    
    private lazy var stackViewCashIn: BaseStackView = {
        let stack = BaseStackView()
        return stack
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.equalSpacing
        stack.spacing = 5
        return stack
    }()
    
    private var id: String?
    private var gpsX: String?
    private var gpsY: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray2
        self.addSubviews()
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        self.stackViewPlace.addArrangedSubview(self.placeTitle)
        self.stackViewPlace.addArrangedSubview(self.place)
        self.stackViewTime.addArrangedSubview(self.workTimeTitle)
        self.stackViewTime.addArrangedSubview(self.workTime)
        self.stackViewCurrency.addArrangedSubview(self.currencyTitle)
        self.stackViewCurrency.addArrangedSubview(self.currency)
        self.stackViewCashIn.addArrangedSubview(self.cashInTitle)
        self.stackViewCashIn.addArrangedSubview(self.cashIn)
        self.stackView.addArrangedSubview(self.stackViewPlace)
        self.stackView.addArrangedSubview(self.stackViewTime)
        self.stackView.addArrangedSubview(self.stackViewCurrency)
        self.stackView.addArrangedSubview(self.stackViewCashIn)
        self.stackView.addArrangedSubview(self.detailedButton)
        self.addSubview(self.stackView)
    }
    
    func configured(place: String, currency: String, time: String, cashIn: String, id: String, gpsX: String, gpsY: String) {
        self.currencyTitle.text = "Валюта:"
        self.cashInTitle.text = "Прием наличных:"
        self.cashIn.text = cashIn
        self.currency.text = currency
        self.place.text = place
        self.id = id
        self.workTime.text = time
        self.gpsX = gpsX
        self.gpsY = gpsY
    }
    
    func configuredFilialsCell(place: String, time: String, number: String, filialId: String, gpsX: String, gpsY: String) {
        self.currencyTitle.text = "Телефон:"
        self.cashInTitle.text = "ID:"
        self.cashIn.text = filialId
        self.currency.text = number
        self.place.text = place
        self.workTime.text = time
        self.id = filialId
        self.gpsX = gpsX
        self.gpsY = gpsY
        
    }
    
    func getCoordinate() -> [String?] {
        [self.gpsX, self.gpsY]
    }
}
