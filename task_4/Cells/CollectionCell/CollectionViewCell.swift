//
//  CollectionViewCell.swift
//  task_4
//
//  Created by Natalia Drozd on 27.12.22.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentificator = "collectionCell"
        
    private lazy var installPlace: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.font = lbl.font.withSize(13)
        return lbl
    }()
    
    private lazy var workTime: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = lbl.font.withSize(13)
        return lbl
    }()
    
    private lazy var currency: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = lbl.font.withSize(13)
        return lbl
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.equalSpacing
        stack.alignment = UIStackView.Alignment.center
        stack.spacing = 2
        stack.addArrangedSubview(installPlace)
        stack.addArrangedSubview(workTime)
        stack.addArrangedSubview(currency)
        return stack
    }()
    
    private var atmId: String?
    private var gpsX: String?
    private var gpsY: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configured(place: String, time: String, currency: String, id: String, gpsX: String, gpsY: String) {
        if currency.isEmpty {
            self.currency.text = "ID:\n\(id)"
        } else {
            self.currency.text = "Валюта:\n\(currency)"
        }
        self.installPlace.text = "Место:\n\(place)"
        self.workTime.text = "Режим работы:\n\(time)"
        self.atmId = id
        self.gpsX = gpsX
        self.gpsY = gpsY
    }
    
    func getCoordinate() -> [String?] {
        [self.gpsX, self.gpsY]
    }
}
