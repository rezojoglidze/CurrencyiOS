//
//  Decimal+Extensions.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 08.03.22.
//

import Foundation

extension Decimal {
    
    func stringValue(rounding: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = rounding
        formatter.maximumFractionDigits = rounding
        return formatter.string(from: self as NSDecimalNumber) ?? ""
    }
}
