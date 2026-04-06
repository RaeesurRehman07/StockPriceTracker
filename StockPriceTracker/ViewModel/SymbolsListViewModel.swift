import Foundation

// MARK: - Notification.Name - 

extension Notification.Name {
    static let stockPricesDidUpdate = Notification.Name("StockPriceTracker.stockPricesDidUpdate")
}

// MARK: - SymbolsListQuote - 

struct SymbolsListQuote {
    let price: Double
    let change: Double
}

// MARK: - SymbolsListItemViewModel - 

struct SymbolsListItemViewModel {
    let title: String
    /// When `nil`, the row has not received a price yet (formatting lives in the view layer).
    let quote: SymbolsListQuote?
}

// MARK: - SymbolsListViewModel - 

final class SymbolsListViewModel {

    // MARK: - Properties - 

    enum SortMode {
        case price
        case change
    }

    private struct PriceEntry {
        let symbol: String
        let price: Double
        let change: Double
    }

    private(set) var sortMode: SortMode = .price

    private var prices: [String: PriceEntry] = [:]

    private let webSocketManager: WebSocketManager

    var onUpdate: (() -> Void)?

    // MARK: - Connection - 

    enum ConnectionState {
        case disconnected
        case connecting
        case connected
    }

    private(set) var connectionState: ConnectionState = .disconnected

    var onConnectionStateChanged: (() -> Void)?

    // MARK: - Lifecycle - 

    init(webSocketManager: WebSocketManager = WebSocketManager()) {
        self.webSocketManager = webSocketManager
        self.webSocketManager.delegate = self
    }

    // MARK: - Public API - 

    /// Call when the list screen appears so the socket connects immediately.
    func connectOnAppear() {
        startConnection()
    }

    func startConnection() {
        connectionState = .connecting
        onConnectionStateChanged?()
        webSocketManager.connect()
    }

    func stopConnection() {
        webSocketManager.disconnect()
        connectionState = .disconnected
        onConnectionStateChanged?()
    }

    var numberOfRows: Int {
        return StockSymbols.count
    }

    func item(at index: Int) -> SymbolsListItemViewModel {
        let symbols = currentSymbolsOrder()
        let symbol = symbols[index]

        if let entry = prices[symbol] {
            let quote = SymbolsListQuote(price: entry.price, change: entry.change)
            return SymbolsListItemViewModel(title: symbol, quote: quote)
        } else {
            return SymbolsListItemViewModel(title: symbol, quote: nil)
        }
    }

    func sortByPrice() {
        sortMode = .price
        onUpdate?()
    }

    func sortByChange() {
        sortMode = .change
        onUpdate?()
    }

    /// Latest quote for a symbol (e.g. symbol detail screen).
    func quote(for symbol: String) -> SymbolsListQuote? {
        guard let entry = prices[symbol] else { return nil }
        return SymbolsListQuote(price: entry.price, change: entry.change)
    }

    // MARK: - Helpers - 

    private func currentSymbolsOrder() -> [String] {
        switch sortMode {
        case .price:
            return StockSymbols.all.sorted { lhs, rhs in
                let lhsPrice = prices[lhs]?.price ?? 0
                let rhsPrice = prices[rhs]?.price ?? 0
                if lhsPrice != rhsPrice { return lhsPrice > rhsPrice }
                return lhs < rhs
            }
        case .change:
            return StockSymbols.all.sorted { lhs, rhs in
                let lhsChange = prices[lhs]?.change ?? 0
                let rhsChange = prices[rhs]?.change ?? 0
                if lhsChange != rhsChange { return lhsChange > rhsChange }
                return lhs < rhs
            }
        }
    }
}

// MARK: - WebSocketManagerDelegate - 

extension SymbolsListViewModel: WebSocketManagerDelegate {
    func webSocketManagerDidConnect(_ manager: WebSocketManager) {
        connectionState = .connected
        onConnectionStateChanged?()
    }

    func webSocketManagerDidDisconnect(_ manager: WebSocketManager, error: Error?) {
        connectionState = .disconnected
        onConnectionStateChanged?()
    }

    func webSocketManager(_ manager: WebSocketManager, didReceiveText message: String) {
        let components = message.split(separator: ":")
        guard components.count == 2,
              let price = Double(components[1]) else {
            return
        }

        let symbol = String(components[0])
        guard StockSymbols.tracked.contains(symbol) else { return }

        let previousPrice = prices[symbol]?.price ?? price
        let change = price - previousPrice

        let entry = PriceEntry(symbol: symbol, price: price, change: change)
        prices[symbol] = entry

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onUpdate?()
            NotificationCenter.default.post(name: .stockPricesDidUpdate, object: self)
        }
    }
}


