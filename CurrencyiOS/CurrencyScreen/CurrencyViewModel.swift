//
//  CurrencyViewModel.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import Foundation

protocol CurrencyViewModelProtocol: AnyObject {
    var collectionViewNumberOfItemsInSection: Int { get }
    
    func pickerViewNumberOfRowsInComponent(isSell: Bool) -> Int
    func pickerViewTitleForRow(isSell: Bool, row: Int) -> String
    func getMyBalanceInfo(with index: Int) -> (Double, String)
    func getSelectedCurrencyFromPickerView(with isSell: Bool, row: Int) -> Currencies
    func checkIfSellCurrencyBalanceIsEnoughToConvertation(fromAmount: Double)
}

class CurrencyViewModel {
    
    weak var view: CurrencyViewProtocol?
    
    private var userBalance: [Currencies: Double] = [
        .eur: 1000,
        .usd: 0,
        .jpy: 0
    ]
    
    private var currentSellCurrency: Currencies = .eur
    private var currentBuyCurrency: Currencies = .usd
    private var availableBuyCurrencies: [Currencies] = []
    private var availableSellCurrencies: [Currencies] = []
    private var convertationCount = 0
    private let percentOfCommissionFee: Double = 7/100
    private var commissionFee: Double = 0
    private let coordinator: CurrencyCoordinator
    
    init(view: CurrencyViewProtocol,
         coordinator: CurrencyCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
}

extension CurrencyViewModel: CurrencyViewModelProtocol {
    
    //MARK: Convertation Logics
    func checkIfSellCurrencyBalanceIsEnoughToConvertation(fromAmount: Double) {
        countCommissionFee(fromAmount: fromAmount)
        let amountWithCommissionFee = fromAmount + commissionFee
        if userBalance[currentSellCurrency] ?? 0 < amountWithCommissionFee {
            coordinator.showAlert(title: "Ohh", text: "Unfortunately, balance isn't enough. Change value pls")
            return
        }
        loadConvertation(fromAmount: fromAmount)
    }
    
    private func countCommissionFee(fromAmount: Double) {
        if convertationCount > 4 { //on the sixth convertation convertationCount value will be 5 because it increase when response comes.
            commissionFee = fromAmount * percentOfCommissionFee
        }
    }
    
    private func loadConvertation(fromAmount: Double) {
        NetworkManager.shared.loadConvertation(fromAmount: fromAmount, fromCurrency: currentSellCurrency.rawValue, toCurrency: currentBuyCurrency.rawValue) { [weak self] response in
            self?.convertationCount += 1
            switch response {
            case .success(let convertation):
                DispatchQueue.main.sync {
                    self?.coordinator.showAlert(title: "Currency converted", text: self?.getSuccessConvertationText(fromAmount: fromAmount, convertation: convertation) ?? "")
                    self?.updateMyBalance(fromAmount, convertation)
                    self?.view?.updateBuyCurrencyAmountLabel(convertation: convertation)
                }
            case .failure(let error):
                self?.coordinator.showAlert(title: "Something went wrong", text: error.localizedDescription)
            }
        }
    }
    
    private func getSuccessConvertationText(fromAmount: Double, convertation: Convertation) -> String {
        return "You have converted \(fromAmount) \(self.currentSellCurrency.rawValue) to \(convertation.amount) \(convertation.currency). Commission Fee - \(String(format: "%.3f", commissionFee))  \(self.currentSellCurrency.rawValue)"
    }
    
    //MARK: My Balance Logics
    private func updateMyBalance(_ fromAmount: Double, _ convertation: Convertation) {
        guard let currentSellCurrencyBalance = userBalance[currentSellCurrency],
              let currentBuyCurrencyBalance = userBalance[currentBuyCurrency],
              let buyCurrencyValue = Double(convertation.amount) else { return }
        
        userBalance[currentSellCurrency] = currentSellCurrencyBalance - (fromAmount + commissionFee)
        userBalance[currentBuyCurrency] = currentBuyCurrencyBalance + buyCurrencyValue
    }
    
    
    //MARK: Picker View data
    func getSelectedCurrencyFromPickerView(with isSell: Bool, row: Int) -> Currencies {
        let selectedCurr = isSell ? availableSellCurrencies[row] : availableBuyCurrencies[row]
        isSell ? (currentSellCurrency = selectedCurr) : (currentBuyCurrency = selectedCurr)
        return selectedCurr
    }
    
    func pickerViewNumberOfRowsInComponent(isSell: Bool) -> Int {
        let curr = isSell ? currentSellCurrency : currentBuyCurrency
        let currencies =  Currencies.allCases.filter { currency in
            return currency != curr
        }
        filterAvailableCurrrencies(isSell: isSell)
        return currencies.count
    }
    
    func pickerViewTitleForRow(isSell: Bool, row: Int) -> String {
        return isSell ? availableSellCurrencies[row].rawValue : availableBuyCurrencies[row].rawValue
    }
    
    private func filterAvailableCurrrencies(isSell: Bool) {
        let filteringCurrency = isSell ? currentSellCurrency: currentBuyCurrency
        let currencies =  Currencies.allCases.filter { currency in
            return currency != filteringCurrency
        }
        
        isSell ? (availableSellCurrencies = currencies) : ( availableBuyCurrencies = currencies)
    }
    
    //MARK: Collection View data
    var collectionViewNumberOfItemsInSection: Int {
        return Currencies.allCases.count
    }
    
    func getMyBalanceInfo(with index: Int) -> (Double, String) {
        let currency = Currencies.allCases[index]
        let balance = userBalance[currency]
        return (balance ?? 0, currency.rawValue)
    }
}
