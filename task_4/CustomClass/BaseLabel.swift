//
//  BaseLabel.swift
//  task_4
//
//  Created by Natalia Drozd on 22.01.23.
//

import UIKit

class BaseLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textColor = .white
        self.numberOfLines = 0
        self.font = self.font.withSize(13)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
}
