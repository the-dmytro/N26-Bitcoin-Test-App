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
        let currency: Currency
        let precision: Int
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
        await repository.dispatch(HistoricalPriceAction.load(days: input.days, currency: input.currency))
        
        let result: Result<MarketChartResponse, APIError> = await apiClient.send(CoinGeckoEndpoint.historicalPrice(days: input.days, currency: input.currency, precision: input.precision))

        switch result {
        case .success(let response):
            let prices = response.prices.map { Price(value: $0.price, currency: input.currency) }
            await repository.dispatch(HistoricalPriceAction.success(prices: prices))
        case .failure(let error):
            await repository.dispatch(HistoricalPriceAction.failure(error))
        }
    }
}