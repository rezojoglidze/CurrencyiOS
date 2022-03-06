//
//  CurrencyViewModel.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import Foundation

enum availableCurrencies: String, CaseIterable {
    case eur
    case usd
    case jpy
}

protocol CurrencyViewModelProtocol: AnyObject {
    var numberOfItemsInSection: Int { get }
    func getMyBalanceInfo(with index: Int) -> (Double, String)
}

class CurrencyViewModel {
    
    weak var view: CurrencyViewProtocol?
    private let userBalance: [availableCurrencies: Double] = [
        availableCurrencies.eur: 1000,
        availableCurrencies.usd: 0,
        availableCurrencies.jpy: 0
    ]
    
    init(view: CurrencyViewProtocol) {
        self.view = view
    }
}

extension CurrencyViewModel: CurrencyViewModelProtocol {
    func getMyBalanceInfo(with index: Int) -> (Double, String) {
        let currency = availableCurrencies.allCases[index]
        let balance = userBalance[currency]
        return (balance ?? 0, currency.rawValue)
    }
    
    var numberOfItemsInSection: Int {
        return availableCurrencies.allCases.count
    }
}
