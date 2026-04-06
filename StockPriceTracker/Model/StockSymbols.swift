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

    // MARK: - Descriptions - 

    /// Short company / instrument description for the symbol detail screen.
    static func companyDescription(for symbol: String) -> String {
        return descriptions[symbol] ?? "Market-traded equity."
    }

    private static let descriptions: [String: String] = [
        "AAPL": "Apple Inc. — consumer electronics, software, and services.",
        "GOOG": "Alphabet Inc. (Class A) — search, ads, and cloud.",
        "TSLA": "Tesla, Inc. — electric vehicles and energy products.",
        "AMZN": "Amazon.com, Inc. — e-commerce and cloud (AWS).",
        "MSFT": "Microsoft Corporation — software, cloud, and productivity.",
        "NVDA": "NVIDIA Corporation — GPUs and AI computing.",
        "META": "Meta Platforms, Inc. — social products and Reality Labs.",
        "NFLX": "Netflix, Inc. — streaming entertainment.",
        "ADBE": "Adobe Inc. — creative and document software.",
        "INTC": "Intel Corporation — processors and data center silicon.",
        "ORCL": "Oracle Corporation — database and enterprise cloud.",
        "IBM": "International Business Machines — hybrid cloud and consulting.",
        "CSCO": "Cisco Systems, Inc. — networking and security.",
        "SAP": "SAP SE — enterprise applications and analytics.",
        "CRM": "Salesforce, Inc. — CRM and customer platform.",
        "UBER": "Uber Technologies, Inc. — mobility and delivery.",
        "LYFT": "Lyft, Inc. — transportation network.",
        "SHOP": "Shopify Inc. — commerce platform for merchants.",
        "SQ": "Block, Inc. (Square) — payments and financial tools.",
        "PYPL": "PayPal Holdings, Inc. — digital payments.",
        "BABA": "Alibaba Group — e-commerce and cloud in China.",
        "V": "Visa Inc. — global payments network.",
        "MA": "Mastercard Incorporated — payment technology.",
        "DIS": "The Walt Disney Company — media and parks.",
        "PEP": "PepsiCo, Inc. — beverages and convenient foods."
    ]
}
