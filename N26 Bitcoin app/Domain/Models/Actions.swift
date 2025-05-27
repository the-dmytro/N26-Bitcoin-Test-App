//
//  Actions.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

enum HistoricalPriceAction: Action {
    case load(days: UInt, currency: Currency)
    case success(prices: [Price])
    case failure(Error)
}

enum CurrentPriceAction: Action {
    case load(currencies: [Currency], precision: Int)
    case success(prices: [Price])
    case failure(Error)
}

enum SelectedDayPriceAction: Action {
    case load(date: Date)
    case success(prices: [Price])
    case failure(Error)
    case reset
}
