//
//  FilterViewController.swift
//  task_4
//
//  Created by Natalia Drozd on 12.01.23.
//

import UIKit
import SnapKit

class FilterViewController: UIViewController {
    
    private var interactor: FilterBusinessLogic?
    
    private lazy var tableCheckBox: UITableView = {
        let table = UITableView()
        table.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.key)
        table.rowHeight = 50
        table.allowsSelection = false
        table.backgroundColor = .systemGray2
        table.dataSource = self
        return table
    }()
    
    private lazy var closedButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Закрыть", for: .normal)
        btn.backgroundColor = .systemTeal
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.cgColor
        btn.addTarget(self, action: #selector(closedButtonTapped), for: .touchUpInside)
        return btn
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.addSubviews()
        self.setup()
    }
    
    override func viewWillLayoutSubviews() {
        self.tableCheckBox.snp.removeConstraints()
        self.closedButton.snp.removeConstraints()
        if self.view.frame.height < 500 {
            self.addConstraintsForHorizontal()
        } else {
            self.addConstraintsForVertical()
        }
    }
    
    func setup() {
        let viewcontroller = self
        let interactor = FilterInteractor()
        viewcontroller.interactor = interactor
    }
    
    private func addSubviews() {
        self.view.addSubview(tableCheckBox)
        self.view.addSubview(closedButton)
    }
    
    private func addConstraintsForHorizontal() {
        self.tableCheckBox.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        self.closedButton.snp.makeConstraints { make in
            make.top.equalTo(tableCheckBox.snp_bottomMargin)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
    }
    
    private func addConstraintsForVertical() {
        self.tableCheckBox.snp.makeConstraints { make in
            make.centerY.centerX.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        self.closedButton.snp.makeConstraints { make in
            make.top.equalTo(tableCheckBox.snp_bottomMargin)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.05)
        }
    }
    
    // MARK: Закрытие окна
    @objc func closedButtonTapped(sender: UIButton) {
        self.tableCheckBox.removeFromSuperview()
        self.closedButton.removeFromSuperview()
        self.view.removeFromSuperview()
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.key, for: indexPath) as? TableViewCell {
            guard let key = TypeInfoBank(rawValue: indexPath.row) else {
                return UITableViewCell()
            }
            if UserDefaults.standard.bool(forKey: key.description) {
                cell.configured(title: key, nameImage: "circle.fill")
            } else {
                cell.configured(title: key, nameImage: "circle")
            }
            if Reachability().isConnectedToNetwork() {
                cell.actionBlock = {
                    if UserDefaults.standard.bool(forKey: key.description) {
                        cell.configured(title: key, nameImage: "circle")
                        UserDefaults.standard.set(false, forKey: key.description)
                    } else {
                        cell.configured(title: key, nameImage: "circle.fill")
                        UserDefaults.standard.set(true, forKey: key.description)
                    }
                    DispatchQueue.main.async {
                        self.interactor?.postMessageToNotification(name: key.description)
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
}
