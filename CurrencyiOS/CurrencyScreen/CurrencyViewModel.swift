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
    
    func pickerViewNumberOfRowsInComponent(isSell: Bool) -> Int
    func pickerViewTitleForRow(isSell: Bool, row: Int) -> String
    func getMyBalanceInfo(with index: Int) -> (Double, String)
    func getPickerViewSelectedCurrency(with isSell: Bool, row: Int) -> AvailableCurrencies
    func checkIfSellCurrencyBalanceIsEnoughToConvertation(fromAmount: Double)
}

class CurrencyViewModel {
    
    weak var view: CurrencyViewProtocol?
    
    private var userBalance: [AvailableCurrencies: Double] = [
        AvailableCurrencies.eur: 1000,
        AvailableCurrencies.usd: 0,
        AvailableCurrencies.jpy: 0
    ]
    
    private var sellCurrentCurrency: AvailableCurrencies = .eur
    private var buyCurrencCurrency: AvailableCurrencies = .usd
    private var currentAvailableBuyCurrencies: [AvailableCurrencies] = []
    private var currentAvailableSellCurrencies: [AvailableCurrencies] = []
    private var convertationCount = 0
    private var percentOfCommissionFee: Double = 7/100
    private var commissionFee: Double = 0
    private var coordinator: CurrencyCoordinator
    
    init(view: CurrencyViewProtocol,
         coordinator: CurrencyCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
}

extension CurrencyViewModel: CurrencyViewModelProtocol {
    
    //MARK: Convertation Logics
    func checkIfSellCurrencyBalanceIsEnoughToConvertation(fromAmount: Double) {
        convertationCount += 1
        countCommissionFee(fromAmount: fromAmount)
        let amountWithCommissionFee = fromAmount + commissionFee
        if userBalance[sellCurrentCurrency] ?? 0 < amountWithCommissionFee {
            coordinator.showAlert(title: "Ohh", text: "\(fromAmount) \(sellCurrentCurrency.rawValue) isnot available in your balance. Change value pls")
            return
        }
        loadConvertation(fromAmount: fromAmount)
    }
    
    private func countCommissionFee(fromAmount: Double) {
        if convertationCount > 1 {
            commissionFee = fromAmount * percentOfCommissionFee
        }
    }
    
    private func loadConvertation(fromAmount: Double) {
        NetworkManager.shared.loadConvertation(fromAmount: fromAmount, fromCurrency: sellCurrentCurrency.rawValue, toCurrency: buyCurrencCurrency.rawValue) { [weak self] response in
            switch response {
            case .success(let convertation):
                DispatchQueue.main.sync {
                    self?.coordinator.showAlert(title: "Currency converted", text: self?.getSuccessConvertationText(fromAmount: fromAmount, convertation: convertation) ?? "")
                    self?.updateMyBalance(fromAmount, convertation)
                    self?.view?.updateBoughtCurrencyValue(convertation: convertation)
                }
            case .failure(let error):
                self?.coordinator.showAlert(title: "Something wrong", text: error.localizedDescription)
            }
        }
    }
    
    private func updateMyBalance(_ fromAmount: Double, _ convertation: Convertation) {
        guard let currentSellCurrencyBalance = userBalance[sellCurrentCurrency],  let currentBuyCurrencyBalance = userBalance[buyCurrencCurrency],
            let buyCurrencyValue = Double(convertation.amount) else { return }
       
        userBalance[sellCurrentCurrency] = currentSellCurrencyBalance - (fromAmount + commissionFee)
        userBalance[buyCurrencCurrency] = currentBuyCurrencyBalance + buyCurrencyValue
    }
    
    private func getSuccessConvertationText(fromAmount: Double, convertation: Convertation) -> String {
        return "You have converted \(fromAmount) \(self.sellCurrentCurrency.rawValue) to \(convertation.amount) \(convertation.currency). Commission Fee - \(String(format: "%.3f", commissionFee))  \(self.sellCurrentCurrency.rawValue)"
    }
    
    
    //MARK: Picker View data
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
    
    //MARK: Collection View data
    var collectionViewNumberOfItemsInSection: Int {
        return AvailableCurrencies.allCases.count
    }
    
    func getMyBalanceInfo(with index: Int) -> (Double, String) {
        let currency = AvailableCurrencies.allCases[index]
        let balance = userBalance[currency]
        return (balance ?? 0, currency.rawValue)
    }
}
