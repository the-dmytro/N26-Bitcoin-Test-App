//
//  PriceHistoryViewModel.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation
import Combine

enum PriceHistoryLoadingState: Equatable {
    case loading
    case loaded([Price])
    case error(Error)

    static func == (lhs: PriceHistoryLoadingState, rhs: PriceHistoryLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsPrices), .loaded(let rhsPrices)):
            return lhsPrices == rhsPrices
        case (.error(let lhsError), .error(let rhsError)): 
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

@MainActor
class PriceHistoryViewModel: ObservableObject {
    
    @Published var currentPriceState: PriceHistoryLoadingState = .loading
    @Published var historicalPriceState: PriceHistoryLoadingState = .loading

    private let repository: AppRepository
    private let historicalPriceUseCase: HistoricalPriceUseCase
    private let currentPriceUseCase: CurrentPriceUseCase
    private var cancellables: Set<AnyCancellable> = []

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
            await historicalPriceUseCase.execute(input: .init(days: 14, currency: .usd))
            await currentPriceUseCase.execute(input: .init(currencies: [.usd], precision: 2))
        }
    }

    func retryCurrentPrice() {
        Task {
            await currentPriceUseCase.execute(input: .init(currencies: [.usd], precision: 2))
        }
    }

    func retryHistoricalPrice() {
        Task {
            await historicalPriceUseCase.execute(input: .init(days: 14, currency: .usd))
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
        case .loaded:
            historicalPriceState = .loaded(prices)
        case .loading:
            historicalPriceState = .loading
        case .loadingError(let error):
            historicalPriceState = .error(error)
        default:
            break
        }
    }

    private func updateCurrentPriceState(prices: [Price], loadingState: LoadingState) {
        switch loadingState {
        case .loaded:
            currentPriceState = .loaded(prices)
        case .loading:
            currentPriceState = .loading
        case .loadingError(let error):
            currentPriceState = .error(error)
        default:
            break
        }
    }
}