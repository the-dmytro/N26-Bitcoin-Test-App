//
//  PriceDetailViewModel.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation
import Combine

@MainActor
class PriceDetailViewModel: ObservableObject {
    private let currencies: Set<Currency> = [.eur, .usd, .gbp]

    private let repository: AppRepository
    private let priceUseCase: DayPriceUseCase
    private var cancellables: Set<AnyCancellable> = []

    let date: Date

    @Published var priceLoadingState: PriceLoadingState = .notLoaded

    init(repository: AppRepository, priceUseCase: DayPriceUseCase, date: Date) {
        self.repository = repository
        self.priceUseCase = priceUseCase
        self.date = date

        setupSubscriptions()
    }
    
    func onAppear() {
        Task {
            await priceUseCase.execute(input: .init(date: date, currencies: Array(currencies)))
        }
    }

    func onDisappear() {
        repository.dispatch(SelectedDayPriceAction.reset)
    }

    func retry() {
        Task {
            await priceUseCase.execute(input: .init(date: date, currencies: Array(currencies)))
        }
    }

    private func setupSubscriptions() {
        repository.observe(\.selectedDay)
            .sink { [weak self] selectedDayState in
                self?.updateSelectedDayState(date: selectedDayState.date, prices: selectedDayState.prices, loadingState: selectedDayState.loadingState)
            }
            .store(in: &cancellables)
    }

    private func updateSelectedDayState(date: Date?, prices: [Price], loadingState: LoadingState) {
        switch loadingState {
        case .loading:
            priceLoadingState = .loading
        case .loaded:
            let filteredPrices = prices.filter { currencies.contains($0.currency) }
            priceLoadingState = .loaded(filteredPrices)
        case .loadingError(let error):
            priceLoadingState = .error(error)
        default:
            break
        }
    }
}