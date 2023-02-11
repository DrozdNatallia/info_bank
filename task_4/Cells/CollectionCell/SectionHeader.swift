//
//  SectionHeader.swift
//  task_4
//
//  Created by Natalia Drozd on 3.01.23.
//

import Foundation
import SnapKit

class SectionHeader: UICollectionReusableView {
    
    static let reuseId = "SectionHeader"
    
    private lazy var title: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .tintColor
        lbl.textAlignment = .center
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.title)
        self.title.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configured(nameCity: String) {
        self.title.text = nameCity
    }
}
