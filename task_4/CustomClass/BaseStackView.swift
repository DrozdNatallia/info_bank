//
//  BaseStackView.swift
//  task_4
//
//  Created by Natalia Drozd on 22.01.23.
//

import UIKit

class BaseStackView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = NSLayoutConstraint.Axis.horizontal
        self.distribution = UIStackView.Distribution.fillProportionally
        self.alignment = UIStackView.Alignment.center
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
}
