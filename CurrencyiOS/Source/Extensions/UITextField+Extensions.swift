//
//  UITextField+Extensions.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 08.03.22.
//

import Foundation
import UIKit

extension UITextField {
    
    func textToDouble(separator: String? = nil) -> Double? {
        let numberformatter = NumberFormatter()
        numberformatter.decimalSeparator = separator ?? Locale.current.decimalSeparator
        return numberformatter.number(from: self.text ?? "")?.doubleValue
    }
}
