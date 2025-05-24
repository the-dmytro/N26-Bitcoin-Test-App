//
//  Actions.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

enum HistoricalPriceAction: Action {
    case load(days: UInt, currencies: [Currency])
    case success(prices: [Price])
    case failure(Error)
}

enum CurrentPriceAction: Action {
    case load(currencies: [Currency])
    case success(price: Price)
    case failure(Error)
}

enum SelectedDayPriceAction: Action {
    case select(date: Date)
    case success(prices: [Price])
    case failure(Error)
}
