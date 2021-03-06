//
//  ResultListExampleViewController.swift
//  AutoCompleteTextFieldExample
//
//  Created by Jacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AutoCompleteTextField

class ResultListExampleViewController: UIViewController, UITextFieldDelegate, AutoCompleteTextFieldDelegate {
    @IBOutlet private var autoCompleteTextField: AutoCompleteTextField!
    @IBOutlet private var resultLabel: UILabel!

    @IBOutlet private var resultLabelTopConstraint: NSLayoutConstraint!

    private let dataSource = ["One", "One Two", "One Two Three", "One Two Three Four", "One Two Three Four Five", "One Two Three Four Six"]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Result List"
        setupAutoCompleteTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setLeftBarButton(
            UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed(_:))), animated: false
        )
    }

    // MARK: - Setup Functions

    private func setupAutoCompleteTextField() {
        autoCompleteTextField.delegate = self
        autoCompleteTextField.autoCompleteDelegate = self
        autoCompleteTextField.load(dataSource: dataSource)
        autoCompleteTextField.maxResultCount = 15
        autoCompleteTextField.resultListOffsetY = 5
        autoCompleteTextField.backgroundColor = .white
        autoCompleteTextField.layer.borderColor = UIColor.black.cgColor
        autoCompleteTextField.layer.borderWidth = 1
        autoCompleteTextField.layer.cornerRadius = 5
        autoCompleteTextField.resultListBackgroundColor = .white
        autoCompleteTextField.resultListLayer.borderColor = UIColor.lightGray.cgColor
        autoCompleteTextField.resultListLayer.borderWidth = 1
        autoCompleteTextField.resultListLayer.cornerRadius = 5
        autoCompleteTextField.resultListSeparatorStyle = .singleLine
        autoCompleteTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.leftViewMode = .always
        autoCompleteTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.rightViewMode = .always
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Automatically select the first available result when return button is hit.
        guard let textField = textField as? AutoCompleteTextField else { return true }
        textField.selectFirstResult()
        textField.resignFirstResponder()
        return true
    }

    // MARK: - AutoCompleteTextFieldDelegate

    func autoCompleteTextField(_ textField: AutoCompleteTextField, didSelect result: AutoCompletable) {
        // Set result text to label when result is selected.
        guard let result = result as? String else { return }
        resultLabel.text = "Selected: \(result)"
    }

    func autoCompleteTextFieldResultListWillShow(_ textField: AutoCompleteTextField) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
            self.resultLabelTopConstraint.constant = textField.currentResultListHeight + 25
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func autoCompleteTextFieldResultListDidHide(_ textField: AutoCompleteTextField) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
            self.resultLabelTopConstraint.constant = 25
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    // MARK: - Actions

    @objc private func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
