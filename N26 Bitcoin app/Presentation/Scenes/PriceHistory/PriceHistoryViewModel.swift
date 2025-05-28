//
//  PriceHistoryViewModel.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation
import Combine

@MainActor
class PriceHistoryViewModel: ObservableObject {
    enum DetailScreenState: Hashable {
        case selected(date: Date)
    }

    private let currency: Currency = .eur
    private let days: UInt = 14
    private let precision: Int = 2
    private let refreshInterval: TimeInterval = 60

    private let repository: AppRepository
    private let historicalPriceUseCase: HistoricalPriceUseCase
    private let currentPriceUseCase: CurrentPriceUseCase
    private let selectedDayUseCase: DayPriceUseCase
    private let refreshTimer: RefreshTimer
    private var cancellables: Set<AnyCancellable> = []

    @Published var currentPriceState: PriceLoadingState = .notLoaded
    @Published var historicalPriceState: PriceLoadingState = .notLoaded
    @Published var selectedDate: Date?

    init(repository: AppRepository,
         historicalPriceUseCase: HistoricalPriceUseCase,
         currentPriceUseCase: CurrentPriceUseCase,
         selectedDayUseCase: DayPriceUseCase,
         refreshTimer: RefreshTimer) {
        self.repository = repository
        self.historicalPriceUseCase = historicalPriceUseCase
        self.currentPriceUseCase = currentPriceUseCase
        self.selectedDayUseCase = selectedDayUseCase
        self.refreshTimer = refreshTimer

        setupSubscriptions()
    }
    
    func onAppear() {
        if currentPriceState == .notLoaded {
            loadCurrentPrice()
        }
        if historicalPriceState == .notLoaded {
            loadHistoricalPrice()
        }
        startRefreshTimer()
    }

    func onDisappear() {
        stopRefreshTimer()
    }

    // MARK: - User actions

    func retryCurrentPrice() {
        loadCurrentPrice()
    }

    func retryHistoricalPrice() {
        loadHistoricalPrice()
    }

    func selectHistoricalPrice(at index: Int) {
        let date = convertToDate(at: index)
        loadPrice(for: date)
    }

    // MARK: - Private functions

    private func loadCurrentPrice() {
        Task {
            await currentPriceUseCase.execute(input: .init(currencies: [currency], precision: precision))
        }
    }
    
    private func loadHistoricalPrice() {
        Task {
            await historicalPriceUseCase.execute(input: .init(days: days, currency: currency, precision: precision))
        }
    }

    private func convertToDate(at index: Int) -> Date {
        Date(timeIntervalSinceNow: -TimeInterval(index * 24 * 60 * 60))
    }

    private func loadPrice(for date: Date) {
        Task {
            await selectedDayUseCase.execute(input: .init(date: date, currencies: [.eur, .usd, .gbp]))
        }
    }

    private func startRefreshTimer() {
        refreshTimer.start(interval: refreshInterval)
    }

    private func stopRefreshTimer() {
        refreshTimer.stop()
    }

    // MARK: - Data

    private func setupSubscriptions() {
        repository.observe(\.historicalPrice)
            .sink { [weak self] historicalPriceState in
                guard let self = self else { return }
                self.updateHistoricalPriceState(prices: historicalPriceState.prices, loadingState: historicalPriceState.loadingState)
            }
            .store(in: &cancellables)
            
        repository.observe(\.currentPrice)
            .sink { [weak self] currentPriceState in
                guard let self = self else { return }
                self.updateCurrentPriceState(prices: currentPriceState.prices, loadingState: currentPriceState.loadingState)
            }
            .store(in: &cancellables)

        repository.observe(\.selectedDay)
            .sink { [weak self] selectedDayState in
                guard let self = self else { return }
                self.updateSelectedDayState(date: selectedDayState.date)
            }
            .store(in: &cancellables)

        refreshTimer.publisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.loadCurrentPrice()
            }
            .store(in: &cancellables)
    }
    
    private func updateHistoricalPriceState(prices: [Price], loadingState: LoadingState) {
        switch loadingState {
        case .notLoaded:
            historicalPriceState = .notLoaded
        case .loaded:
            let prices = prices.reversed().dropFirst().map {
                Price(value: $0.value, currency: $0.currency)
            }
            historicalPriceState = .loaded(prices)
        case .loading:
            historicalPriceState = .loading
        case .loadingError(let error):
            historicalPriceState = .error(error)
        }
    }

    private func updateCurrentPriceState(prices: [Price], loadingState: LoadingState) {
        switch loadingState {
        case .notLoaded:
            currentPriceState = .notLoaded
        case .loaded:
            currentPriceState = .loaded(prices)
        case .loading:
            currentPriceState = .loading
        case .loadingError(let error):
            currentPriceState = .error(error)
        }
    }

    private func updateSelectedDayState(date: Date?) {
        selectedDate = date
    }
}
