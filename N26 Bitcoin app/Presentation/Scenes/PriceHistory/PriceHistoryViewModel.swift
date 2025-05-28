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
    private let currency: Currency = .eur
    private let days: UInt = 14
    private let precision: Int = 2
    private let refreshInterval: TimeInterval = 5

    private let repository: AppRepository
    private let historicalPriceUseCase: HistoricalPriceUseCase
    private let currentPriceUseCase: CurrentPriceUseCase
    private let refreshTimer: RefreshTimer
    private var cancellables: Set<AnyCancellable> = []

    @Published var currentPriceState: PriceLoadingState = .notLoaded
    @Published var historicalPriceState: PriceLoadingState = .notLoaded

    init(repository: AppRepository,
         historicalPriceUseCase: HistoricalPriceUseCase,
         currentPriceUseCase: CurrentPriceUseCase,
         refreshTimer: RefreshTimer) {
        self.repository = repository
        self.historicalPriceUseCase = historicalPriceUseCase
        self.currentPriceUseCase = currentPriceUseCase
        self.refreshTimer = refreshTimer

        setupSubscriptions()
    }
    
    func onAppear() {
        loadCurrentPrice()
        loadHistoricalPrice()
        startRefreshTimer()
    }

    // MARK: - User actions

    func retryCurrentPrice() {
        loadCurrentPrice()
    }

    func retryHistoricalPrice() {
        loadHistoricalPrice()
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

    private func startRefreshTimer() {
        refreshTimer.start(interval: refreshInterval)
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
}