//
//  InlineCompletionExampleViewController.swift
//  AutoCompleteTextFieldExample
//
//  Created by Jacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AutoCompleteTextField

class InlineCompletionExampleViewController: UIViewController, UITextFieldDelegate, AutoCompleteTextFieldDelegate {
    @IBOutlet private var autoCompleteTextField: AutoCompleteTextField!
    @IBOutlet private var previousResultButton: UIButton!
    @IBOutlet private var nextResultButton: UIButton!
    @IBOutlet private var resultLabel: UILabel!

    private let dataSource = ["One", "One Two", "One Two Three", "One Two Three Four", "One Two Three Four Five", "One Two Three Four Six"]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Result List"
        setupAutoCompleteTextField()
        setupButtons()
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
        autoCompleteTextField.shouldShowResultList = false
        autoCompleteTextField.shouldShowInlineAutoCompletion = true
        autoCompleteTextField.maxResultCount = 15
        autoCompleteTextField.backgroundColor = .white
        autoCompleteTextField.layer.borderColor = UIColor.black.cgColor
        autoCompleteTextField.layer.borderWidth = 1
        autoCompleteTextField.layer.cornerRadius = 5
        autoCompleteTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.leftViewMode = .always
        autoCompleteTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.rightViewMode = .always
    }

    private func setupButtons() {
        previousResultButton.layer.cornerRadius = previousResultButton.frame.height / 2
        previousResultButton.clipsToBounds = true
        nextResultButton.layer.cornerRadius = nextResultButton.frame.height / 2
        nextResultButton.clipsToBounds = true
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Automatically select the first available result when return button is hit.
        guard let textField = textField as? AutoCompleteTextField else { return true }
        textField.selectCurrentInlineAutoCompletionResult()
        textField.resignFirstResponder()
        return true
    }

    // MARK: - AutoCompleteTextFieldDelegate

    func autoCompleteTextField(_ textField: AutoCompleteTextField, didSelect result: AutoCompletable) {
        // Set result text to label when result is selected.
        guard let result = result as? String else { return }
        resultLabel.text = "Selected: \(result)"
    }

    // MARK: - Actions

    @objc private func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func previousResultButtonPressed(_ sender: UIButton) {
        autoCompleteTextField.previousResultForInlineAutoCompletion()
    }

    @IBAction private func nextResultButtonPressed(_ sender: UIButton) {
        autoCompleteTextField.nextResultForInlineAutoCompeletion()
    }
}
