//
//  HistoricalPriceUseCase.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

struct HistoricalPriceUseCase: UseCase {
    struct HistoricalPriceInput {
        let days: UInt
        let currencies: [Currency]
    }

    typealias Input = HistoricalPriceInput
    typealias Output = Void
    typealias RepoStateType = AppState
    typealias RepoReducerType = AppReducer

    private let repository: AppRepository
    private let apiClient: APIClient

    init(repository: AppRepository, apiClient: APIClient) {
        self.repository = repository
        self.apiClient = apiClient
    }

    func execute(input: HistoricalPriceInput) async -> Void {
        await repository.dispatch(HistoricalPriceAction.load(days: input.days, currencies: input.currencies))
        
        let result: Result<MarketChartResponse, APIError> = await apiClient.send(CoinGeckoEndpoint.historicalPrice(days: input.days, currencies: input.currencies))

        switch result {
        case .success(let response):
            guard let targetCurrency = input.currencies.first else {
                await repository.dispatch(HistoricalPriceAction.failure(APIError.invalidResponse))
                return
            }
            let prices = response.prices.map { Price(value: $0.price, currency: targetCurrency) }
            await repository.dispatch(HistoricalPriceAction.success(prices: prices))
        case .failure(let error):
            await repository.dispatch(HistoricalPriceAction.failure(error))
        }
    }
}