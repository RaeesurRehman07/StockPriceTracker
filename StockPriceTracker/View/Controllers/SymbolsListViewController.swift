//
//  ViewController.swift
//  StockPriceTracker
//
//  Created by Raees Ur rehman on 01/04/2026.
//

import UIKit

// MARK: - SymbolsListViewController - 

final class SymbolsListViewController: UIViewController {

    @IBOutlet weak var connectionStatusContainer: UIView!
    @IBOutlet weak var connectionIndicatorView: UIView!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var sortControl: UISegmentedControl!

    // MARK: - Properties - 

    private let viewModel = SymbolsListViewModel()

    // MARK: - Lifecycle - 

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureConnectionHeader()
        configureSegmentedControl()
        bindViewModel()
        viewModel.connectOnAppear()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        connectionStatusContainer.applyShadow(
            color: .black,
            opacity: 0.25,
            offset: CGSize(width: 0, height: 3),
            radius: 6,
            cornerRadius: 12
        )
    }
    // MARK: - Configuration -

    private func configureNavigation() {
        title = "Stocks"
    }

    private func configureConnectionHeader() {
        connectionIndicatorView.backgroundColor = .systemGray

        connectionStatusLabel.font = .preferredFont(forTextStyle: .subheadline)
        connectionStatusLabel.textColor = .label
        connectionStatusLabel.text = "Disconnected"

        connectionButton.addTarget(self, action: #selector(connectionButtonTapped), for: .touchUpInside)
        connectionButton.imageView?.contentMode = .scaleAspectFit

        updateConnectionUI()
    }

    private func configureSegmentedControl() {
        sortControl.selectedSegmentIndex = viewModel.sortMode == .price ? 0 : 1
        sortControl.addTarget(self, action: #selector(sortChanged(_:)), for: .valueChanged)
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.contentTableView.reloadData()
        }
        viewModel.onConnectionStateChanged = { [weak self] in
            self?.updateConnectionUI()
        }
    }

    private func updateConnectionUI() {

        switch viewModel.connectionState {
        case .connecting:
            connectionIndicatorView.backgroundColor = .systemOrange
            connectionStatusLabel.text = "Connecting…"
            connectionButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        case .connected:
            connectionIndicatorView.backgroundColor = .systemGreen
            connectionStatusLabel.text = "Connected"
            connectionButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        case .disconnected:
            connectionIndicatorView.backgroundColor = .systemRed
            connectionStatusLabel.text = "Disconnected"
            connectionButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }

        connectionButton.isEnabled = true
    }

    // MARK: - Actions - 

    @objc
    private func connectionButtonTapped() {
        switch viewModel.connectionState {
        case .connected, .connecting:
            viewModel.stopConnection()
        case .disconnected:
            viewModel.startConnection()
        }
    }

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
    }
}

// MARK: - UITableViewDataSource - 

extension SymbolsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let item = viewModel.item(at: indexPath.row)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.attributedText = SymbolsListRowFormatting.detailAttributed(for: item)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
