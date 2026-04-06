//
//  StockPriceTrackerTests.swift
//  StockPriceTrackerTests
//
//  Created by Raees Ur rehman on 01/04/2026.
//

import XCTest
@testable import StockPriceTracker

final class StockPriceTrackerTests: XCTestCase {

    // MARK: - StockSymbols - 

    func testStockSymbols_hasTwentyFiveUniqueTrackedSymbols() {
        XCTAssertEqual(StockSymbols.count, 25)
        XCTAssertEqual(StockSymbols.tracked.count, 25)
        XCTAssertEqual(Set(StockSymbols.all).count, 25)
    }

    // MARK: - SymbolsListViewModel - 

    func testSymbolsListViewModel_rowCountMatchesTrackedSymbols() {
        let viewModel = SymbolsListViewModel()

        XCTAssertEqual(viewModel.numberOfRows, StockSymbols.count)

        let first = viewModel.item(at: 0)
        XCTAssertFalse(first.title.isEmpty)
        XCTAssertTrue(StockSymbols.tracked.contains(first.title))
    }

    func testSymbolsListViewModel_changesSortMode() {
        let viewModel = SymbolsListViewModel()

        XCTAssertEqual(viewModel.sortMode, .price)

        viewModel.sortByChange()
        XCTAssertEqual(viewModel.sortMode, .change)

        viewModel.sortByPrice()
        XCTAssertEqual(viewModel.sortMode, .price)
    }

    // MARK: - PriceFeedMessageParser - 

    func testPriceFeedMessageParser_validTrackedSymbol() {
        let parsed = PriceFeedMessageParser.parse("AAPL:180.5")
        XCTAssertEqual(parsed?.symbol, "AAPL")
        XCTAssertEqual(parsed?.price, 180.5)
    }

    func testPriceFeedMessageParser_invalidFormat() {
        XCTAssertNil(PriceFeedMessageParser.parse("no-colon"))
        XCTAssertNil(PriceFeedMessageParser.parse("AAPL:notANumber"))
        XCTAssertNil(PriceFeedMessageParser.parse("AAPL"))
    }

    func testPriceFeedMessageParser_untrackedSymbol() {
        XCTAssertNil(PriceFeedMessageParser.parse("ZZZZ:100"))
    }
}

