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

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    
    var viewModel: CurrencyViewModelProtocol!

    static func instantiate() -> CurrencyViewController {
        let storyBoard = UIStoryboard(name: "Currency", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as? CurrencyViewController ?? .init()
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }
    
    private func setupView() {
        submitBtn.setTitle("sumbit".uppercased(), for: .normal)
        submitBtn.layer.cornerRadius = 24
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: String(describing: MyBalancesTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MyBalancesTableViewCell.self))
        
        tableView.register(UINib(nibName: String(describing: CurrencyExchangeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CurrencyExchangeTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension CurrencyViewController: CurrencyViewProtocol {
    
}

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeaderInSection(with: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(with: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let allCasses = CurrencyViewSection.allCases
        
        switch allCasses[indexPath.section] {
        case .myBalances:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyBalancesTableViewCell.self)) as? MyBalancesTableViewCell
            return cell ?? UITableViewCell()
        case .exchange:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CurrencyExchangeTableViewCell.self)) as? CurrencyExchangeTableViewCell
            return cell ?? UITableViewCell()
        }
    }
}
