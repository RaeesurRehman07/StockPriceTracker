import Foundation

// MARK: - StockSymbols - 

/// Canonical list of 25 tracked symbols for the scrollable list and WebSocket price feed.
enum StockSymbols {

    static let all: [String] = [
        "AAPL", "GOOG", "TSLA", "AMZN", "MSFT",
        "NVDA", "META", "NFLX", "ADBE", "INTC",
        "ORCL", "IBM", "CSCO", "SAP", "CRM",
        "UBER", "LYFT", "SHOP", "SQ", "PYPL",
        "BABA", "V", "MA", "DIS", "PEP"
    ]

    static var count: Int { all.count }

    static let tracked: Set<String> = Set(all)
}
