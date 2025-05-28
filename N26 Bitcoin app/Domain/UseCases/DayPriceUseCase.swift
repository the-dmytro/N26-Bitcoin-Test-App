//
//  DayPriceUseCase.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

struct DayPriceUseCase: UseCase {
    struct DayPriceInput {
        let date: Date
        let currencies: [Currency]
    }

    typealias Input = DayPriceInput
    typealias Output = Void
    typealias RepoStateType = AppState
    typealias RepoReducerType = AppReducer

    private let repository: AppRepository
    private let apiClient: APIClient

    init(repository: AppRepository, apiClient: APIClient) {
        self.repository = repository
        self.apiClient = apiClient
    }

    func execute(input: DayPriceInput) async -> Void {
        await repository.dispatch(SelectedDayPriceAction.load(date: input.date))

        let result: Result<CoinHistoryResponse, APIError> = await apiClient.send(CoinGeckoEndpoint.priceAtDate(date: input.date))

        switch result {
        case .success(let response):
            let prices = input.currencies.compactMap { currency in
                if let price = response.prices[currency] {
                    return Price(value: price, currency: currency)
                }
                else {
                    return nil
                }
            }
            await repository.dispatch(SelectedDayPriceAction.success(prices: prices))
        case .failure(let error):
            await repository.dispatch(SelectedDayPriceAction.failure(error))
        }
    }
}
