//
//  PriceLoadingState.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 27/5/25.
//

import Foundation
import Combine

enum PriceLoadingState: Equatable {
    case notLoaded
    case loading
    case loaded([Price])
    case error(Error)

    static func == (lhs: PriceLoadingState, rhs: PriceLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.notLoaded, .notLoaded):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsPrices), .loaded(let rhsPrices)):
            return lhsPrices == rhsPrices
        case (.error(let lhsError), .error(let rhsError)): 
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}