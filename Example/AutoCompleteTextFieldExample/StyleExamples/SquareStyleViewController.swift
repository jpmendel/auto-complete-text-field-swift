//
//  SquareStyleViewController.swift
//  AutoCompleteTextFieldExample
//
//  Created by Jacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AutoCompleteTextField

class SquareStyleViewController: UIViewController {
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
        autoCompleteTextField.load(dataSource: dataSource)
        autoCompleteTextField.shouldShowResultList = true
        autoCompleteTextField.shouldShowInlineAutoCompletion = true
        autoCompleteTextField.maxResultCount = 15
        autoCompleteTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.leftViewMode = .always
        autoCompleteTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.rightViewMode = .always
    }

    @objc private func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
