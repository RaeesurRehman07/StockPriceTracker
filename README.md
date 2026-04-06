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

From the repo root. **`xcodebuild test` needs a concrete simulator** (`generic/platform=iOS Simulator` is not enough).

1. List destinations your Xcode actually has (names change with Xcode/iOS SDK — e.g. newer kits may offer **iPhone 17** but not **iPhone 16**):

   ```bash
   xcodebuild -scheme StockPriceTracker -showdestinations
   ```

2. Copy `name=` and `OS=` from a line under **Available destinations** (pick any **iOS Simulator** row, e.g. `iPhone 17` @ `26.4`).

3. Run tests:

   ```bash
   xcodebuild test \
     -scheme StockPriceTracker \
     -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' \
     -only-testing:StockPriceTrackerTests \
     CODE_SIGN_IDENTITY="" \
     CODE_SIGNING_REQUIRED=NO \
     CODE_SIGNING_ALLOWED=NO
   ```

   Adjust `name=` / `OS=` to match step 1. Using `OS=latest` works when that device type exists.

GitHub Actions (`.github/workflows/ci.yml`) pins a simulator name that matches the **CI** Xcode image; locally, always align with **your** `-showdestinations` list.
