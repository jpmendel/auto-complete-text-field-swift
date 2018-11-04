//
//  VibrantBackgroundViewController.swift
//  AutoCompleteTextFieldExample
//
//  Created by Jacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AutoCompleteTextField

class VibrantBackgroundViewController: UIViewController {
    @IBOutlet private var autoCompleteTextField: AutoCompleteTextField!

    private var gradientLayer: CAGradientLayer?

    private let dataSource = ["One", "One Two", "One Two Three", "One Two Three Four", "One Two Three Four Five", "One Two Three Four Six"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupAutoCompleteTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setTransparentNavigationBar(withTint: .white)
        navigationController?.navigationBar.barStyle = .black
        navigationItem.setLeftBarButton(
            UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed(_:))), animated: false
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }

    private func setupGradientBackground() {
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [
            UIColor(red: 145 / 255, green: 96 / 255, blue: 230 / 255, alpha: 1.0).cgColor,
            UIColor(red: 80 / 255, green: 120 / 255, blue: 200 / 255, alpha: 1.0).cgColor
        ]
        gradientLayer?.startPoint = CGPoint(x: 0.6, y: 0.0)
        gradientLayer?.endPoint = CGPoint(x: 0.4, y: 1.0)
        view.layer.insertSublayer(gradientLayer!, at: 0)
        gradientLayer?.frame = view.bounds
    }

    private func setupAutoCompleteTextField() {
        autoCompleteTextField.load(dataSource: dataSource)
        autoCompleteTextField.shouldShowResultList = true
        autoCompleteTextField.shouldShowInlineAutoCompletion = true
        autoCompleteTextField.maxResultCount = 15
        autoCompleteTextField.resultListOffsetY = 15
        autoCompleteTextField.textColor = UIColor.white
        autoCompleteTextField.tintColor = UIColor.white
        autoCompleteTextField.resultListTextColor = UIColor.white
        autoCompleteTextField.resultListBackgroundColor = UIColor.white.withAlphaComponent(0.2)
        autoCompleteTextField.resultListLayer.cornerRadius = 8
        autoCompleteTextField.attributedPlaceholder = NSAttributedString(
            string: autoCompleteTextField.placeholder ?? "",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        autoCompleteTextField.inlineAutoCompletionTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.4),
            NSAttributedString.Key.backgroundColor: UIColor.clear
        ]
        autoCompleteTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.leftViewMode = .always
        autoCompleteTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: autoCompleteTextField.frame.height))
        autoCompleteTextField.rightViewMode = .always
    }

    @objc private func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
