//
//  AmountConvertView.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import UIKit

@IBDesignable class AmountConvertViewWrapper : NibWrapperView<AmountConvertView> { }

protocol AmountConvertViewDelegate: AnyObject {
    func didTappedCurrencyChooseBtn(isSell: Bool)
}

class AmountConvertView: UIView {
    
    weak var delegate: AmountConvertViewDelegate?
    
    @IBOutlet weak var sellCurrencyAmountTextField: UITextField!
        
    
    @IBAction func sellCurrencyChooseBtnTapped(_ sender: Any) {
        delegate?.didTappedCurrencyChooseBtn(isSell: true)
    }
    
    @IBAction func buyCurrencyChooseBtnTapped(_ sender: Any) {
        delegate?.didTappedCurrencyChooseBtn(isSell: false)
    }
}


