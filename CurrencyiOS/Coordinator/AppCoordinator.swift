//
//  AppCoordinator.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var childrenCoordinators: [Coordinator] { get }
    func start()
}

class AppCoordinator: Coordinator {
   private(set) var childrenCoordinators: [Coordinator] = []
    
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController()
        let currencyCoordindator = CurrencyCoordinator(navigationController: navigationController)
        childrenCoordinators.append(currencyCoordindator)
        currencyCoordindator.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
