//
//  SimpleStyleViewController.swift
//  AutoCompleteTextFieldExample
//
//  Created by Jacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AutoCompleteTextField

class SimpleStyleViewController: UIViewController, AutoCompleteTextFieldDelegate {
    @IBOutlet private var autoCompleteTextField: AutoCompleteTextField!

    private let dataSource = ["One", "One Two", "One Two Three", "One Two Three Four", "One Two Three Four Five", "One Two Three Four Six"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAutoCompleteTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setTransparentNavigationBar(withTint: .black)
        navigationItem.setLeftBarButton(
            UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed(_:))), animated: false
        )
    }

    private func setupAutoCompleteTextField() {
        autoCompleteTextField.autoCompleteDelegate = self
        autoCompleteTextField.load(dataSource: dataSource)
        autoCompleteTextField.shouldShowResultList = true
        autoCompleteTextField.shouldShowInlineAutoCompletion = true
        autoCompleteTextField.maxResultCount = 15
        autoCompleteTextField.resultListOffsetY = -autoCompleteTextField.frame.height
        autoCompleteTextField.resultListContentInset.top = autoCompleteTextField.frame.height
        autoCompleteTextField.layer.borderColor = UIColor.black.cgColor
        autoCompleteTextField.layer.borderWidth = 1
        autoCompleteTextField.layer.cornerRadius = 8
        autoCompleteTextField.resultListBackgroundColor = .white
        autoCompleteTextField.resultListLayer.borderColor = UIColor.black.cgColor
        autoCompleteTextField.resultListLayer.borderWidth = 1
        autoCompleteTextField.resultListLayer.cornerRadius = 8
        autoCompleteTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.leftViewMode = .always
        autoCompleteTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.rightViewMode = .always
    }

    func autoCompleteTextFieldResultListWillShow(_ textField: AutoCompleteTextField) {
        textField.backgroundColor = .clear
        textField.layer.borderColor = UIColor.clear.cgColor
    }

    func autoCompleteTextFieldResultListDidHide(_ textField: AutoCompleteTextField) {
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.black.cgColor
    }

    @objc private func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
