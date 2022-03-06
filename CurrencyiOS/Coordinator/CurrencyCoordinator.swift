//
//  CurrencyCoordinator.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import Foundation
import UIKit

class CurrencyCoordinator: Coordinator {
    var childrenCoordinators: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let view = CurrencyViewController.instantiate()
        let viewModel = CurrencyViewModel(view: view, coordinator: self)
        view.viewModel = viewModel
        navigationController.setViewControllers([view], animated: true)
    }
    
    
    func showAlert(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(alertAction)
        guard let presentedViewController = navigationController.visibleViewController else { return }
        presentedViewController.present(alert, animated: true, completion: nil)
    }
}
