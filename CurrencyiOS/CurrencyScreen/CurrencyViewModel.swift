//
//  CurrencyViewModel.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import Foundation

enum AvailableCurrencies: String, CaseIterable {
    case eur
    case usd
    case jpy
}

protocol CurrencyViewModelProtocol: AnyObject {
    var collectionViewNumberOfItemsInSection: Int { get }
    
    var sellCurrentCurrency: AvailableCurrencies { get set }
    var buyCurrencCurrency: AvailableCurrencies { get set }
    var currentAvailableBuyCurrencies: [AvailableCurrencies] { get }
    var currentAvailableSellCurrencies: [AvailableCurrencies] { get }
    func pickerViewNumberOfRowsInComponent(isSell: Bool) -> Int
    func pickerViewTitleForRow(isSell: Bool, row: Int) -> String
    func getMyBalanceInfo(with index: Int) -> (Double, String)
    func getPickerViewSelectedCurrency(with isSell: Bool, row: Int) -> AvailableCurrencies
}

class CurrencyViewModel {
    
    weak var view: CurrencyViewProtocol?
    
    private let userBalance: [AvailableCurrencies: Double] = [
        AvailableCurrencies.eur: 1000,
        AvailableCurrencies.usd: 0,
        AvailableCurrencies.jpy: 0
    ]
    
    var sellCurrentCurrency: AvailableCurrencies = .eur
    var buyCurrencCurrency: AvailableCurrencies = .usd
    var currentAvailableBuyCurrencies: [AvailableCurrencies] = []
    var currentAvailableSellCurrencies: [AvailableCurrencies] = []
    init(view: CurrencyViewProtocol) {
        self.view = view
    }
}

extension CurrencyViewModel: CurrencyViewModelProtocol {
    func getPickerViewSelectedCurrency(with isSell: Bool, row: Int) -> AvailableCurrencies {
        let selectedCurr = isSell ? currentAvailableSellCurrencies[row] : currentAvailableBuyCurrencies[row]
        isSell ? (sellCurrentCurrency = selectedCurr) : (buyCurrencCurrency = selectedCurr)
        
        return selectedCurr
    }
    
    func pickerViewNumberOfRowsInComponent(isSell: Bool) -> Int {
        let curr = isSell ? sellCurrentCurrency : buyCurrencCurrency
        let currencies =  AvailableCurrencies.allCases.filter { currency in
            return currency != curr
        }
        filterCurrentAvailableCurrrencies(isSell: isSell)
        return currencies.count
    }
    
    func pickerViewTitleForRow(isSell: Bool, row: Int) -> String {
        return isSell ? currentAvailableSellCurrencies[row].rawValue : currentAvailableBuyCurrencies[row].rawValue
    }
    
    private func filterCurrentAvailableCurrrencies(isSell: Bool) {
        let FilteringCurrency = isSell ? sellCurrentCurrency: buyCurrencCurrency
        let currencies =  AvailableCurrencies.allCases.filter { currency in
            return currency != FilteringCurrency
        }
        
        isSell ? (currentAvailableSellCurrencies = currencies) : ( currentAvailableBuyCurrencies = currencies)
    }
    
    func getMyBalanceInfo(with index: Int) -> (Double, String) {
        let currency = AvailableCurrencies.allCases[index]
        let balance = userBalance[currency]
        return (balance ?? 0, currency.rawValue)
    }
    
    var collectionViewNumberOfItemsInSection: Int {
        return AvailableCurrencies.allCases.count
    }
}
