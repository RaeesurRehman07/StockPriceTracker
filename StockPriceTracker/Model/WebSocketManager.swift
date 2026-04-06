import Foundation

// MARK: - WebSocketManagerDelegate - 

protocol WebSocketManagerDelegate: AnyObject {
    func webSocketManagerDidConnect(_ manager: WebSocketManager)
    func webSocketManagerDidDisconnect(_ manager: WebSocketManager, error: Error?)
    func webSocketManager(_ manager: WebSocketManager, didReceiveText text: String)
}

// MARK: - WebSocketManager - 

final class WebSocketManager {

    weak var delegate: WebSocketManagerDelegate?

    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession
    private var didNotifyConnected = false

    private var connectionDesired = false

    private var reconnectAttempt = 0
    private var pendingReconnect: DispatchWorkItem?

    /// Sends one random price per symbol on each tick, echoed back by the server.
    private var liveSendTimer: Timer?
    private let liveTickInterval: TimeInterval = 5.0

    // MARK: - Initializer - 

    init(session: URLSession = .shared) {
        self.session = session
    }

    deinit {
        stopLivePriceFeed()
        pendingReconnect?.cancel()
    }

    // MARK: - Public API - 

    func connect() {
        connectionDesired = true
        reconnectAttempt = 0
        pendingReconnect?.cancel()
        pendingReconnect = nil
        openSocketIfNeeded()
    }

    func disconnect() {
        connectionDesired = false
        reconnectAttempt = 0
        pendingReconnect?.cancel()
        pendingReconnect = nil

        stopLivePriceFeed()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        didNotifyConnected = false

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.webSocketManagerDidDisconnect(self, error: nil)
        }
    }

    func send(message: String) {
        let payload = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(payload) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.handleConnectionLoss(error: error)
                }
            }
        }
    }

    // MARK: - Socket lifecycle - 

    private func openSocketIfNeeded() {
        guard connectionDesired else { return }
        guard webSocketTask == nil else { return }
        guard let url = URL(string: "wss://ws.postman-echo.com/raw") else { return }

        didNotifyConnected = false
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        receiveMessage()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.sendRandomPriceMessage()
        }
    }

    private func handleConnectionLoss(error: Error?) {
        stopLivePriceFeed()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        didNotifyConnected = false

        guard connectionDesired else {
            delegate?.webSocketManagerDidDisconnect(self, error: error)
            return
        }

        scheduleReconnect()
    }

    private func scheduleReconnect() {
        guard connectionDesired else { return }

        reconnectAttempt += 1
        let delay = min(30.0, pow(2.0, Double(min(reconnectAttempt, 5))))

        pendingReconnect?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.openSocketIfNeeded()
        }
        pendingReconnect = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    // MARK: - Live feed - 

    private func startLivePriceFeed() {
        stopLivePriceFeed()

        sendRandomPricesForAllSymbols()

        let timer = Timer(timeInterval: liveTickInterval, repeats: true) { [weak self] _ in
            self?.sendRandomPricesForAllSymbols()
        }
        liveSendTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopLivePriceFeed() {
        liveSendTimer?.invalidate()
        liveSendTimer = nil
    }

    /// One random price per tracked symbol each tick (25 messages → 25 echoes).
    private func sendRandomPricesForAllSymbols() {
        for symbol in StockSymbols.all {
            let price = Double.random(in: 50 ... 1500)
            send(message: "\(symbol):\(price)")
        }
    }

    private func sendRandomPriceMessage() {
        guard let symbol = StockSymbols.all.randomElement() else { return }
        let price = Double.random(in: 50 ... 1500)
        send(message: "\(symbol):\(price)")
    }

    // MARK: - Receive - 

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.handleConnectionLoss(error: error)
                }

            case .success(let message):
                switch message {
                case .string(let text):
                    if !self.didNotifyConnected {
                        self.didNotifyConnected = true
                        self.reconnectAttempt = 0
                        self.pendingReconnect?.cancel()
                        self.pendingReconnect = nil
                        DispatchQueue.main.async {
                            self.delegate?.webSocketManagerDidConnect(self)
                            self.startLivePriceFeed()
                        }
                    }
                    DispatchQueue.main.async {
                        self.delegate?.webSocketManager(self, didReceiveText: text)
                    }

                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        if !self.didNotifyConnected {
                            self.didNotifyConnected = true
                            self.reconnectAttempt = 0
                            self.pendingReconnect?.cancel()
                            self.pendingReconnect = nil
                            DispatchQueue.main.async {
                                self.delegate?.webSocketManagerDidConnect(self)
                                self.startLivePriceFeed()
                            }
                        }
                        DispatchQueue.main.async {
                            self.delegate?.webSocketManager(self, didReceiveText: text)
                        }
                    }

                @unknown default:
                    break
                }

                self.receiveMessage()
            }
        }
    }
}
