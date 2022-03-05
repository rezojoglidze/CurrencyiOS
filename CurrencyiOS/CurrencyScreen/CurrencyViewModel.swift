//
//  CurrencyViewModel.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import Foundation
import UIKit

enum CurrencyViewSection: String, CaseIterable {
    case myBalances = "MY BALANCES"
    case exchange = "CURRENCY EXCHNGES"
}

enum availableCurrencies: CaseIterable {
    case eur
    case usd
    case jpy
}

protocol CurrencyViewModelProtocol: AnyObject {
    var numberOfSections: Int { get }
    func titleForHeaderInSection(with section: Int) -> String
    func numberOfRowsInSection(with section: Int) -> Int
}

class CurrencyViewModel {
    
    weak var view: CurrencyViewProtocol?
    
    init(view: CurrencyViewProtocol) {
        self.view = view
    }
    
}

extension CurrencyViewModel: CurrencyViewModelProtocol {
    
    func numberOfRowsInSection(with section: Int) -> Int {
        let allCases = CurrencyViewSection.allCases
        
        switch allCases[section] {
        case .myBalances:
            return availableCurrencies.allCases.count
        case .exchange:
            return 1
        }
    }
    
    func titleForHeaderInSection(with section: Int) -> String {
        return CurrencyViewSection.allCases[section].rawValue
    }
    
    var numberOfSections: Int {
        return CurrencyViewSection.allCases.count
    }
    
}
