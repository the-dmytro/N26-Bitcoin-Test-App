//
//  States.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

public struct HistoricalPriceState: State {
    public var prices: [Price] = []
    public var loadingState: LoadingState = .notLoaded
}

public struct TodayPriceState: State {
    public var price: Price?
    public var loadingState: LoadingState = .notLoaded
}

public struct SelectedDayPriceState: State {
    public var date: Date?
    public var prices: [Price] = []
    public var loadingState: LoadingState = .notLoaded
}

public struct AppState: State {
    public var historicalPrice = HistoricalPriceState()
    public var todayPrice      = TodayPriceState()
    public var selectedDay     = SelectedDayPriceState()
}