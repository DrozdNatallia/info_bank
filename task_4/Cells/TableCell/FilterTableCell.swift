//
//  FilterTableCell.swift
//  task_4
//
//  Created by Natalia Drozd on 14.01.23.
//

import Foundation
import SnapKit

class TableViewCell: UITableViewCell {
    static let key = "TableViewCell"
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = lbl.font.withSize(20)
        return lbl
    }()
    
    private lazy var checkButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "circle"), for: .normal)
        btn.tintColor = .systemTeal
        btn.addTarget(self, action: #selector(addFilter), for: .touchUpInside)
        return btn
    }()

    var actionBlock: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.checkButton)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        checkButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configured(title: TypeInfoBank, nameImage: String) {
        switch title {
        case .atm:
            self.titleLabel.text = "Банкоматы"
        case .infobox:
            self.titleLabel.text = "Инфокиоски"
        default:
            self.titleLabel.text = "Филиалы"
        }
        self.checkButton.setImage(UIImage(systemName: nameImage), for: .normal)
    }
    
    @objc func addFilter() {
        self.actionBlock?()
    }
}
