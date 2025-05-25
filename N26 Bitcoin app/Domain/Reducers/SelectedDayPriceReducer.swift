//
//  SelectedDayPriceReducer.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

struct SelectedDayPriceReducer: Reducer {
    typealias AppStateType = SelectedDayPriceState

    func reduce(state: SelectedDayPriceState, action: Action) -> SelectedDayPriceState {
        var state = state

        switch action {
        case let action as SelectedDayPriceAction:
            switch action {
            case .load(let date):
                state.date = date
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
