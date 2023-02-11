//
//  NetworkProvaider.swift
//  task_4
//
//  Created by Natalia Drozd on 9.01.23.
//

import UIKit

protocol NetworkProvaiderProtocol {
    func getAtmFromURL (completion: @escaping ([InfoAtmModel]?) -> Void)
    func getInfoboxFromUrl (completion: @escaping ([InfoboxModel]?) -> Void)
    func getFilialsFromUrl(completion: @escaping ([InfoFilialsModel]?) -> Void)
}

class NetworkProvaider: NetworkProvaiderProtocol {
    
    // MARK: Получение данных с банкоматами
    func getAtmFromURL (completion: @escaping ([InfoAtmModel]?) -> Void) {
            if let url = URL(string: Constants.baseBankApi) {
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
                    guard self != nil else { return }
                    if error != nil {
                        completion(nil)
                    }
                    if let data = data {
                        do {
                            let result = try JSONDecoder().decode([InfoAtmModel].self, from: data)
                            completion(result)
                        } catch {
                            completion(nil)
                        }
                    }
                }
                task.resume()
            }
        }
    
    // MARK: Получение данных с инфокиосками
    func getInfoboxFromUrl (completion: @escaping ([InfoboxModel]?) -> Void) {
        if let url = URL(string: Constants.baseInfoboxApi) {
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
                    guard self != nil else { return }
                    if error != nil {
                        completion(nil)
                    }
                    if let data = data {
                        do {
                            let result = try JSONDecoder().decode([InfoboxModel].self, from: data)
                            completion(result)
                        } catch {
                            completion(nil)
                        }
                    }
                }
                task.resume()
            }
    }
    
    // MARK: Получение данных с филиалами
    func getFilialsFromUrl(completion: @escaping ([InfoFilialsModel]?) -> Void) {
        if let url = URL(string: Constants.baseFilialsApi) {
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
                    guard self != nil else { return }
                    if error != nil {
                        completion(nil)
                    }
                    if let data = data {
                        do {
                            let result = try JSONDecoder().decode([InfoFilialsModel].self, from: data)
                            completion(result)
                        } catch {
                            completion(nil)
                        }
                    }
                }
                task.resume()
            }
    }
}
