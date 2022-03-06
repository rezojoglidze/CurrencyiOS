//
//  Constants.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 06.03.22.
//

import Foundation

struct Constants {
    
    static func getCurrencyExchangeUrl(fromAmount: Double, fromCurrency: String, toCurrency: String) -> URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "api.evp.lt"
        components.path = "/currency/commercial/exchange/\(fromAmount)-\(fromCurrency)/\(toCurrency)/latest"
        return URL(string: components.string ?? "")
    }
}
