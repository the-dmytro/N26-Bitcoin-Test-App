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

    private let repository: AppRepository
    private let historicalPriceUseCase: HistoricalPriceUseCase
    private let currentPriceUseCase: CurrentPriceUseCase
    private var cancellables: Set<AnyCancellable> = []

    @Published var currentPriceState: PriceLoadingState = .notLoaded
    @Published var historicalPriceState: PriceLoadingState = .notLoaded

    init(repository: AppRepository,
         historicalPriceUseCase: HistoricalPriceUseCase,
         currentPriceUseCase: CurrentPriceUseCase) {
        self.repository = repository
        self.historicalPriceUseCase = historicalPriceUseCase
        self.currentPriceUseCase = currentPriceUseCase

        setupSubscriptions()
    }
    
    func onAppear() {
        Task {
            await historicalPriceUseCase.execute(input: .init(days: days, currency: currency))
            await currentPriceUseCase.execute(input: .init(currencies: [currency], precision: precision))
        }
    }

    func retryCurrentPrice() {
        Task {
            await currentPriceUseCase.execute(input: .init(currencies: [currency], precision: precision))
        }
    }

    func retryHistoricalPrice() {
        Task {
            await historicalPriceUseCase.execute(input: .init(days: days, currency: currency))
        }
    }

    private func setupSubscriptions() {
        repository.observe(\.historicalPrice)
            .sink { [weak self] historicalPriceState in
                self?.updateHistoricalPriceState(prices: historicalPriceState.prices, loadingState: historicalPriceState.loadingState)
            }
            .store(in: &cancellables)
            
        repository.observe(\.currentPrice)
            .sink { [weak self] currentPriceState in
                self?.updateCurrentPriceState(prices: currentPriceState.prices, loadingState: currentPriceState.loadingState)
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