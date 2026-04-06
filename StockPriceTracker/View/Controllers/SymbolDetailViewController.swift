import UIKit

// MARK: - SymbolDetailViewController - 

final class SymbolDetailViewController: UIViewController {

    // MARK: - Properties - 

    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var symbol: String!
    weak var listViewModel: SymbolsListViewModel?

    private var priceObserver: NSObjectProtocol?

    // MARK: - Initializer - 

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        if let priceObserver = priceObserver {
            NotificationCenter.default.removeObserver(priceObserver)
        }
    }

    // MARK: - Lifecycle - 

    override func viewDidLoad() {
        super.viewDidLoad()
        title = symbol

        configureContent()
        bindPriceUpdates()
        refreshPriceDisplay()
    }

    // MARK: - Configuration - 

    private func configureContent() {
        descriptionLabel.text = StockSymbols.companyDescription(for: symbol)
    }

    private func bindPriceUpdates() {
        guard let listViewModel = listViewModel else { return }
        priceObserver = NotificationCenter.default.addObserver(
            forName: .stockPricesDidUpdate,
            object: listViewModel,
            queue: .main
        ) { [weak self] _ in
            self?.refreshPriceDisplay()
        }
    }

    // MARK: - Updates - 

    private func refreshPriceDisplay() {
        guard let listViewModel = listViewModel else { return }
        let quote = listViewModel.quote(for: symbol)
        let item = SymbolsListItemViewModel(title: symbol, quote: quote)
        priceLabel.attributedText = SymbolsListRowFormatting.detailAttributed(for: item)
    }
}
