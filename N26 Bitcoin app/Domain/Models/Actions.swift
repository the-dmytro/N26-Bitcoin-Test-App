//
//  Actions.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

enum HistoricalPriceAction: Action {
    case load
    case success([Price])
    case failure(Error)
}

enum TodayPriceAction: Action {
    case load
    case success(Price)
    case failure(Error)
}

enum SelectedDayPriceAction: Action {
    case select(Date)
    case success([Price])
    case failure(Error)
}
