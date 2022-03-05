//
//  CurrencyViewModel.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import Foundation

protocol CurrencyViewModelProtocol: AnyObject {
    
}

class CurrencyViewModel {
    
    weak var view: CurrencyViewProtocol?
    
    init(view: CurrencyViewProtocol) {
        self.view = view
    }
    
}

extension CurrencyViewModel: CurrencyViewModelProtocol {
    
}
