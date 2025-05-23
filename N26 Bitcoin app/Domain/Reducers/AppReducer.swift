//
//  AppReducer.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

struct AppReducer: Reducer {
    typealias AppStateType = AppState

    private let historicalPriceReducer = HistoricalPriceReducer()
    private let todayPriceReducer = TodayPriceReducer()
    private let selectedDayPriceReducer = SelectedDayPriceReducer()

    func reduce(state: AppState, action: Action) -> AppState {
        var state = state
        state.historicalPrice = historicalPriceReducer.reduce(state: state.historicalPrice, action: action)
        state.todayPrice      = todayPriceReducer.reduce(state: state.todayPrice, action: action)
        state.selectedDay     = selectedDayPriceReducer.reduce(state: state.selectedDay, action: action)
        return state
    }
}
