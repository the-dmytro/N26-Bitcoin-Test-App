//
//  States.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

struct HistoricalPriceState: State {
    var prices: [Price] = []
    var loadingState: LoadingState = .notLoaded
}

struct CurrentPriceState: State {
    var prices: [Price] = []
    var loadingState: LoadingState = .notLoaded
}

struct SelectedDayPriceState: State {
    var date: Date?
    var prices: [Price] = []
    var loadingState: LoadingState = .notLoaded
}

struct AppState: State {
    var historicalPrice = HistoricalPriceState()
    var currentPrice    = CurrentPriceState()
    var selectedDay     = SelectedDayPriceState()
}