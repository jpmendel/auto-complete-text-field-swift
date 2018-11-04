//
//  MenuViewController.swift
//  AutoCompleteTextFieldExample
//
//  Created by Jacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var menuTableView: UITableView!

    private let usageExamples = ["Result List", "Inline Completion", "Linked Data Source"]
    private let styleExamples = ["Rounded", "Square", "Simple", "Vibrant"]

    private var defaultNavigationBarBackgroundImage: UIImage?
    private var defaultNavigationBarShadow: UIImage?
    private var defaultNavigationBarBackgroundColor: UIColor?
    private var defaultNavigationBarTintColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AutoCompleteTextField"
        menuTableView.delegate = self
        menuTableView.dataSource = self
        defaultNavigationBarBackgroundImage = navigationController?.navigationBar.backgroundImage(for: .default)
        defaultNavigationBarShadow = navigationController?.navigationBar.shadowImage
        defaultNavigationBarBackgroundColor = navigationController?.navigationBar.backgroundColor
        defaultNavigationBarTintColor = navigationController?.navigationBar.tintColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.setBackgroundImage(defaultNavigationBarBackgroundImage, for: .default)
        navigationController?.navigationBar.shadowImage = defaultNavigationBarShadow
        navigationController?.navigationBar.backgroundColor = defaultNavigationBarBackgroundColor
        navigationController?.navigationBar.tintColor = defaultNavigationBarTintColor
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return usageExamples.count
        } else {
            return styleExamples.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Usage Examples"
        } else {
            return "Style Examples"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "MenuTableViewCell")
        if indexPath.section == 0 {
            cell.textLabel?.text = usageExamples[indexPath.row]
            if usageExamples[indexPath.row] == "Linked Data Source" {
                cell.textLabel?.textColor = .lightGray
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = styleExamples[indexPath.row]
        }
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController: UIViewController?
        if indexPath.section == 0 {
            if usageExamples[indexPath.row] == "Result List" {
                viewController = ResultListExampleViewController()
            } else if usageExamples[indexPath.row] == "Inline Completion" {
                viewController = InlineCompletionExampleViewController()
            }
        } else if indexPath.section == 1 {
            if styleExamples[indexPath.row] == "Rounded" {
                viewController = RoundedStyleViewController()
            } else if styleExamples[indexPath.row] == "Square" {
                viewController = SquareStyleViewController()
            } else if styleExamples[indexPath.row] == "Simple" {
                viewController = SimpleStyleViewController()
            } else if styleExamples[indexPath.row] == "Vibrant" {
                viewController = VibrantBackgroundViewController()
            }
        }
        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
