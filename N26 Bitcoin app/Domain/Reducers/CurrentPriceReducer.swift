//
//  CurrentPriceReducer.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

struct CurrentPriceReducer: Reducer {
    typealias AppStateType = CurrentPriceState

    func reduce(state: CurrentPriceState, action: Action) -> CurrentPriceState {
        var state = state

        switch action {
        case let action as CurrentPriceAction:
            switch action {
            case .load:
                state.loadingState = .loading
            case .success(let prices):
                state.prices = prices
                state.loadingState = .loaded
            case .failure(let error):
                state.loadingState = .loadingError(error)
            }
        default:
            break
        }

        return state
    }
}
