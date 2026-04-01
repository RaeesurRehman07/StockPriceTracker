//
//  StockPriceTrackerTests.swift
//  StockPriceTrackerTests
//
//  Created by Raees Ur rehman on 01/04/2026.
//

import XCTest
@testable import StockPriceTracker

final class StockPriceTrackerTests: XCTestCase {

    // MARK: - SymbolsListViewModel - 

    func testSymbolsListViewModel_hasDummyItems() {
        let viewModel = SymbolsListViewModel()

        XCTAssertEqual(viewModel.numberOfRows, 3)

        let first = viewModel.item(at: 0)
        XCTAssertEqual(first.title, "AAPL")
    }

    func testSymbolsListViewModel_changesSortMode() {
        let viewModel = SymbolsListViewModel()

        XCTAssertEqual(viewModel.sortMode, .price)

        viewModel.sortByChange()
        XCTAssertEqual(viewModel.sortMode, .change)

        viewModel.sortByPrice()
        XCTAssertEqual(viewModel.sortMode, .price)
    }
}

