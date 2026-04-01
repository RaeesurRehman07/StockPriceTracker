import Foundation

// MARK: - SymbolsListItemViewModel - 

struct SymbolsListItemViewModel {
    let title: String
    let subtitle: String
}

// MARK: - SymbolsListViewModel - 

final class SymbolsListViewModel {

    // MARK: - Properties - 

    enum SortMode {
        case price
        case change
    }

    private(set) var sortMode: SortMode = .price

    private var items: [SymbolsListItemViewModel] = [
        SymbolsListItemViewModel(title: "AAPL", subtitle: "$180.00 (+1.2%)"),
        SymbolsListItemViewModel(title: "GOOG", subtitle: "$140.50 (+0.5%)"),
        SymbolsListItemViewModel(title: "TSLA", subtitle: "$220.30 (-2.1%)")
    ]

    // MARK: - Lifecycle - 

    init() {}

    // MARK: - Public API - 

    var numberOfRows: Int {
        return items.count
    }

    func item(at index: Int) -> SymbolsListItemViewModel {
        return items[index]
    }

    func sortByPrice() {
        sortMode = .price
    }

    func sortByChange() {
        sortMode = .change
    }
}

