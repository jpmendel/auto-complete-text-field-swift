//
//  LinkedDataSourceExampleViewController.swift
//  AutoCompleteTextFieldExample
//
//  Created by Jacob on 11/4/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AutoCompleteTextField

class LinkedDataSourceExampleViewController: UIViewController, UITextFieldDelegate, AutoCompleteTextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var autoCompleteTextField: AutoCompleteTextField!
    @IBOutlet private var resultLabel: UILabel!
    @IBOutlet private var dataTableView: UITableView!

    private let dataSource = ["One", "One Two", "One Two Three", "One Two Three Four", "One Two Three Four Five", "One Two Three Four Six"]
    private var tableViewData: [String] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Linked Data Source"
        setupAutoCompleteTextField()
        setupTableView()
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
        autoCompleteTextField.shouldShowInlineAutoCompletion = false
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

    private func setupTableView() {
        dataTableView.delegate = self
        dataTableView.dataSource = self
        tableViewData = dataSource
    }

    // MARK: - AutoCompleteTextFieldDelegate

    func autoCompleteTextField(_ textField: AutoCompleteTextField, didFilter results: [AutoCompletable]?) {
        if let results = results as? [String] {
            tableViewData = results
        } else {
            tableViewData = textField.dataSource as? [String] ?? []
        }
        dataTableView.reloadData()
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DataTableViewCell")
        cell.textLabel?.text = tableViewData[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result: String?
        if autoCompleteTextField.filteredResults.count > 0 {
            result = autoCompleteTextField.filteredResults[indexPath.row] as? String
        } else {
            result = autoCompleteTextField.dataSource[indexPath.row] as? String
        }
        resultLabel.text = "Selected: \(result ?? "Nothing")"
    }

    // MARK: - Actions

    @objc private func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
