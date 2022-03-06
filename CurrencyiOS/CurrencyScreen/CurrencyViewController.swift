//
//  ViewController.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import UIKit

protocol CurrencyViewProtocol: AnyObject {
    func updateBoughtCurrencyValue(convertation: Convertation)
}

class CurrencyViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var myBalanceCollectionView: UICollectionView!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var BoughtCurrencyValueLabel: UILabel!
    @IBOutlet private weak var sellCurrencyAmountTextField: UITextField!
    @IBOutlet private weak var sellButton: UIButton!
    @IBOutlet private weak var BuyButton: UIButton!
    
    private lazy var pickerView: UIPickerView = UIPickerView()
    private lazy var toolBar = UIToolbar()
    private var isSell: Bool = false

    var viewModel: CurrencyViewModelProtocol!
    
    static func instantiate() -> CurrencyViewController {
        let storyBoard = UIStoryboard(name: "Currency", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as? CurrencyViewController ?? .init()
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    
    @IBAction func sellCurrencyChooseButtonTapped(_ sender: Any) {
        isSell = true
        showPickerView()
    }
    
    @IBAction func buyCurrencyChooseButtonTapped(_ sender: Any) {
        isSell = false
        showPickerView()
    }
    
    @IBAction func submitButtonnTapped(_ sender: Any) {
        guard let fromAmount = Double(sellCurrencyAmountTextField.text ?? "0") else { return }
        viewModel.checkIfSellCurrencyBalanceIsEnoughToConvertation(fromAmount: fromAmount)
    }
    
    
    private func setupView() {
        submitButton.setTitle("submit".uppercased(), for: .normal)
        submitButton.layer.cornerRadius = 24
    }
    
    private func showPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        pickerView.setValue(UIColor.black, forKey: "textColor")
        pickerView.autoresizingMask = .flexibleWidth
        pickerView.contentMode = .center
        pickerView.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
           self.view.addSubview(pickerView)
                
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
           toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))]
           self.view.addSubview(toolBar)
    }
    
    @objc func doneButtonTapped() {
        let index = pickerView.selectedRow(inComponent: 0)
        updateCurrencyButtons(index: index)
        toolBar.removeFromSuperview()
        pickerView.removeFromSuperview()
    }
    
    private func updateCurrencyButtons(index: Int) {
        let selectedCurr = viewModel.getSelectedCurrencyFromPickerView(with: isSell, row: index)
        let button = isSell ? sellButton : BuyButton
        button?.setTitle(selectedCurr.rawValue.uppercased(), for: .normal)
    }

    private func setupCollectionView() {
        myBalanceCollectionView.register(UINib(nibName: String(describing: MyBalancesCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MyBalancesCell.self))
        myBalanceCollectionView.dataSource = self
        myBalanceCollectionView.delegate = self
    }
    
    
    private func setupKeyboardObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}

extension CurrencyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.pickerViewNumberOfRowsInComponent(isSell: isSell)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.pickerViewTitleForRow(isSell: isSell, row: row)
    }
}

extension CurrencyViewController: CurrencyViewProtocol {
    func updateBoughtCurrencyValue(convertation: Convertation) {
        self.BoughtCurrencyValueLabel.text = convertation.amount
        self.myBalanceCollectionView.reloadData()
    }
}

extension CurrencyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.collectionViewNumberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyBalancesCell.self), for: indexPath) as? MyBalancesCell
        let info = viewModel.getMyBalanceInfo(with: indexPath.row)
        cell?.fill(text: "\(String(format: "%.1f", info.0)) \(info.1.uppercased())")
        return cell ?? UICollectionViewCell()
    }
}
