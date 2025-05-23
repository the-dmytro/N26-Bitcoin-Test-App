//
//  TodayPriceReducer.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

struct TodayPriceReducer: Reducer {
    typealias AppStateType = TodayPriceState

    func reduce(state: TodayPriceState, action: Action) -> TodayPriceState {
        var state = state

        switch action {
        case let action as TodayPriceAction:
            switch action {
            case .load:
                state.loadingState = .loading
            case .success(let price):
                state.price = price
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
