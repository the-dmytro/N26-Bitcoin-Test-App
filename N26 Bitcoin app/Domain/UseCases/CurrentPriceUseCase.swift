//
//  CurrentPriceUseCase.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 24/5/25.
//

import Foundation

struct CurrentPriceUseCase: UseCase {
    struct CurrentPriceInput {
        let currencies: [Currency]
        let precision: Int
    }

    typealias Input = CurrentPriceInput
    typealias Output = Void
    typealias RepoStateType = AppState
    typealias RepoReducerType = AppReducer

    private let repository: AppRepository
    private let apiClient: APIClient

    init(repository: AppRepository, apiClient: APIClient) {
        self.repository = repository
        self.apiClient = apiClient
    }

    func execute(input: CurrentPriceInput) async -> Void {
        await repository.dispatch(CurrentPriceAction.load(currencies: input.currencies, precision: input.precision))

        let result: Result<SimplePriceResponse, APIError> = await apiClient.send(CoinGeckoEndpoint.currentPrice(currencies: input.currencies, precision: input.precision))

        switch result {
        case .success(let response):
            let prices = input.currencies.compactMap { currency in
                response.prices[.bitcoin]?[currency].map {
                    Price(value: $0, currency: currency)
                }
            }
            await repository.dispatch(CurrentPriceAction.success(prices: prices))
        case .failure(let error):
            await repository.dispatch(CurrentPriceAction.failure(error))
        }
        return ()
    }
}