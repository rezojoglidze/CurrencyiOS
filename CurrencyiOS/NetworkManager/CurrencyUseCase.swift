//
//  NetworkManager.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 06.03.22.
//

import Foundation

protocol CurrencyUseCase {
    func loadConvertation(fromAmount: Decimal, fromCurrency: String, toCurrency: String,
                          completionHandler: @escaping (Result<Convertation, Error>) -> Void)
}

final class DefaultCurrencyUseCases {
    static let shared: CurrencyUseCase = DefaultCurrencyUseCases()
    private init() { }
}

extension DefaultCurrencyUseCases: CurrencyUseCase {
    func loadConvertation(fromAmount: Decimal,
                          fromCurrency: String,
                          toCurrency: String,
                          completionHandler: @escaping (Result<Convertation, Error>) -> Void) {
        guard let url = Constants.getCurrencyExchangeUrl(fromAmount: fromAmount, fromCurrency: fromCurrency, toCurrency: toCurrency) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let convertation = try jsonDecoder.decode(Convertation.self, from: data)
                    completionHandler(.success(convertation))
                } catch {
                    completionHandler(.failure(error))
                }
            }
        }.resume()
    }
}
