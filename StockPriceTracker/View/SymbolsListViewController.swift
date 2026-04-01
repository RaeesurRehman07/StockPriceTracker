//
//  ViewController.swift
//  StockPriceTracker
//
//  Created by Raees Ur rehman on 01/04/2026.
//

import UIKit

final class SymbolsListViewController: UIViewController {

    // MARK: - Properties - 

    private let viewModel = SymbolsListViewModel()

    // MARK: - Lifecycle - 

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SymbolsListViewController loaded")
        configureNavigation()
    }

    // MARK: - Configuration - 

    private func configureNavigation() {
        title = "Stocks"
    }
}
