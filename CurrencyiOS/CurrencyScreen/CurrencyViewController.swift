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
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var submitBtn: UIButton!
    @IBOutlet private weak var myBalanceCollectionView: UICollectionView!
    @IBOutlet private weak var BoughtCurrencyValue: UILabel!
    @IBOutlet private weak var sellCurrencyAmountTextField: UITextField!
    @IBOutlet private weak var sellButton: UIButton!
    @IBOutlet private weak var BuyButton: UIButton!

    private var pickerView: UIPickerView = UIPickerView()
    private var toolBar = UIToolbar()

    var viewModel: CurrencyViewModelProtocol!
    private var isSell: Bool = false
    
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
    
    
    @IBAction func sellCurrencyChooseBtnTapped(_ sender: Any) {
        isSell = true
        showPickerView()
    }
    
    @IBAction func buyCurrencyChooseBtnTapped(_ sender: Any) {
        isSell = false
        showPickerView()
    }
    
    
    private func setupView() {
        submitBtn.setTitle("sumbit".uppercased(), for: .normal)
        submitBtn.layer.cornerRadius = 24
    }
    
    private func showPickerView() {
        pickerView = UIPickerView.init()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        pickerView.setValue(UIColor.black, forKey: "textColor")
        pickerView.autoresizingMask = .flexibleWidth
        pickerView.contentMode = .center
        pickerView.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
           self.view.addSubview(pickerView)
                   
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
           toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
           self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        pickerView.removeFromSuperview()
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
        return isSell ? viewModel.currentAvailableSellCurrencies[row].rawValue : viewModel.currentAvailableBuyCurrencies[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurr =  isSell ? viewModel.currentAvailableSellCurrencies[row] : viewModel.currentAvailableBuyCurrencies[row]
        
        let btn = isSell ? sellButton : BuyButton
        isSell ? (viewModel.sellCurrentCurrency = selectedCurr) : (viewModel.buyCurrencCurrency = selectedCurr)
        btn?.setTitle(selectedCurr.rawValue.uppercased(), for: .normal)
    }
}

extension CurrencyViewController: CurrencyViewProtocol {
    
}

extension CurrencyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.collectionViewNumberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyBalancesCell.self), for: indexPath) as? MyBalancesCell
        let info = viewModel.getMyBalanceInfo(with: indexPath.row)
        cell?.fill(text: "\(info.0) \(info.1.uppercased())")
        return cell ?? UICollectionViewCell()
    }
}
