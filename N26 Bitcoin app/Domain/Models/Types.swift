//
//  Types.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

enum Currency: String {
    case usd = "usd"
    case eur = "eur"
    case gbp = "gbp"
}

struct Price: Equatable {
    let value: Double
    let currency: Currency
}

enum LoadingState: Equatable {
    case notLoaded
    case loading
    case loaded
    case loadingError(Error)

    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.notLoaded, .notLoaded):
            return true
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.loadingError(let lhsError), .loadingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription // Comparison by localizedDescription for simplicity of the test app
        default:
            return false
        }
    }
}