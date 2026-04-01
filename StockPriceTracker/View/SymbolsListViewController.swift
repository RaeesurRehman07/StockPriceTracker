//
//  ViewController.swift
//  StockPriceTracker
//
//  Created by Raees Ur rehman on 01/04/2026.
//

import UIKit

// MARK: - SymbolsListViewController - 

final class SymbolsListViewController: UIViewController {

    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var sortControl: UISegmentedControl!
    // MARK: - Properties - 

    private let viewModel = SymbolsListViewModel()

    // MARK: - Lifecycle - 

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureTableView()
        configureSegmentedControl()
    }

    // MARK: - Configuration - 

    private func configureNavigation() {
        title = "Stocks"
    }

    private func configureTableView() {
        contentTableView.dataSource = self
    }

    private func configureSegmentedControl() {
        sortControl.selectedSegmentIndex = 0
        sortControl.addTarget(self, action: #selector(sortChanged(_:)), for: .valueChanged)
    }

    // MARK: - Actions - 

    @objc
    private func sortChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.sortByPrice()
        case 1:
            viewModel.sortByChange()
        default:
            break
        }
        contentTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource - 

extension SymbolsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let item = viewModel.item(at: indexPath.row)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
