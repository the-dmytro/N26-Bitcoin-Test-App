//
//  Types.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

public enum Currency: String {
    case usd = "usd"
    case eur = "eur"
    case gbp = "gbp"
}

public struct Price {
    public let value: Double
    public let currency: Currency
}

public enum LoadingState {
    case notLoaded
    case loading
    case loaded
    case error(Error)
}