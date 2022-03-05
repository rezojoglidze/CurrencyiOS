//
//  ViewController.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import UIKit

protocol CurrencyViewProtocol: AnyObject {
    
}

class CurrencyViewController: UIViewController {

    
    var viewModel: CurrencyViewModelProtocol!
    
    static func instantiate() -> CurrencyViewController {
        let storyBoard = UIStoryboard(name: "Currency", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as? CurrencyViewController ?? .init()
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        self.navigationController?.navigationBar.isHidden = false

        UINavigationBar.appearance().tintColor = .black
        navigationController?.navigationBar.tintColor = .blue
        navigationController?.title = "Currency Converter"
    }


}

extension CurrencyViewController: CurrencyViewProtocol {
    
}

