# StockPriceTracker

Real-time stock list (Postman Echo WebSocket) with MVVM-style layering, symbol detail, sorting, and connection controls.

Requirements: Xcode 16 or later. The `.xcodeproj` uses `objectVersion` 77; Xcode 15.x cannot open it (*future Xcode project file format*).

## Architecture (concise)

| Layer | Role |
|--------|------|
| **View** | `SymbolsListViewController`, `SymbolDetailViewController`, `SymbolsListRowFormatting` (UIKit / attributed strings only in view layer). |
| **ViewModel** | `SymbolsListViewModel` — connection state, sorted rows, in-memory quotes; observes `WebSocketManager` delegate. |
| **Model / services** | `StockSymbols`, `PriceFeedMessageParser` (pure parse for tests), `WebSocketManager` (URLSession WebSocket + reconnect). |
| **Cross-screen updates** | `NotificationCenter` (`.stockPricesDidUpdate`) so detail refreshes when the shared view model’s prices change. |

**Scaling / multi-region (next steps):** inject a `PriceFeedService` protocol (region-specific URL), move quotes to a `Repository`, add dependency injection for previews and tests.

## Testing strategy

- **Unit tests** (`StockPriceTrackerTests`): symbol catalog invariants, view model row count / sort mode, **`PriceFeedMessageParser`** (valid, invalid, untracked) — no network.
- **Future:** mock `WebSocketManager` via protocol for delegate-driven VM tests; UI tests for navigation.

## CI

From the repo root:

```bash
xcodebuild test -scheme StockPriceTracker -destination 'generic/platform=iOS Simulator' -only-testing:StockPriceTrackerTests
```

Or pick a named simulator (e.g. iPhone 16) if you prefer.

GitHub Actions: see `.github/workflows/ci.yml`.
