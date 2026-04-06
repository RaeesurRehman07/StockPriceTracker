import Foundation

// MARK: - PriceFeedMessageParser - 

/// Parses echo lines `SYMBOL:price` for tracked tickers only (testable without WebSocket).
enum PriceFeedMessageParser {

    struct Parsed: Equatable {
        let symbol: String
        let price: Double
    }

    static func parse(_ text: String) -> Parsed? {
        let parts = text.split(separator: ":")
        guard parts.count == 2, let price = Double(parts[1]) else { return nil }
        let symbol = String(parts[0])
        guard StockSymbols.tracked.contains(symbol) else { return nil }
        return Parsed(symbol: symbol, price: price)
    }
}
