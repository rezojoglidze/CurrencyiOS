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

    @IBOutlet weak var sdaddasdsadsa: UITextField!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var submitBtn: UIButton!
    @IBOutlet private weak var myBalanceCollectionView: UICollectionView!
    @IBOutlet private weak var amountConvertView: AmountConvertView!
    
    private let pickerView: UIPickerView = UIPickerView()
    var viewModel: CurrencyViewModelProtocol!
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
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
    
    private func setupView() {
        submitBtn.setTitle("sumbit".uppercased(), for: .normal)
        submitBtn.layer.cornerRadius = 24
        amountConvertView.delegate = self
    }
    
    private func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClick))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sdaddasdsadsa.inputView = pickerView
        sdaddasdsadsa.inputAccessoryView = toolBar
    }
    
    
    @objc func doneClick() {
        print("dsada")
//        curTextfield?.resignFirstResponder()
//        if let section = tableView.headerView(forSection: .zero) as? StatementHeaderViewCell {
//            if curTextfield == toDateTextField {
//                section.changeDate(toDate: toDate ?? Date())
//            } else {
//                section.changeDate(fromDate: fromDate ?? Date())
//            }
//            loadNewTransactions()
//            fromdatePicker.maximumDate = toDate
//            todatePicker.minimumDate = fromDate
//        }
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
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "21213132"
    }
}

extension CurrencyViewController: CurrencyViewProtocol {
    
}

extension CurrencyViewController: AmountConvertViewDelegate {
    func didTappedCurrencyChooseBtn(isSell: Bool) {
      
        picker = UIPickerView.init()
            picker.delegate = self
            picker.dataSource = self
            picker.backgroundColor = UIColor.white
            picker.setValue(UIColor.black, forKey: "textColor")
            picker.autoresizingMask = .flexibleWidth
            picker.contentMode = .center
            picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
            self.view.addSubview(picker)
                    
            toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
            toolBar.barStyle = .blackTranslucent
            toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
            self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
}

extension CurrencyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyBalancesCell.self), for: indexPath) as? MyBalancesCell
        let info = viewModel.getMyBalanceInfo(with: indexPath.row)
        cell?.fill(text: "\(info.0) \(info.1.uppercased())")
        return cell ?? UICollectionViewCell()
    }
}
