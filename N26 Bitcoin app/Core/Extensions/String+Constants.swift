//
//  String+Constants.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

extension String {
    // MARK: - HTTP Methods
    static let httpMethodGET = "GET"
    
    // MARK: - Content Types
    static let contentTypeJSON = "application/json"
    
    // MARK: - HTTP Headers
    static let headerAccept = "Accept"
    
    // MARK: - API Endpoints
    static let coinGeckoBaseURL = "https://api.coingecko.com/api/v3"
    static let bitcoinMarketChartPath = "/coins/bitcoin/market_chart"
    static let bitcoinHistoryPath = "/coins/bitcoin/history"
    
    // MARK: - Query Parameter Names
    static let queryParamIds = "ids"
    static let queryParamVsCurrency = "vs_currency"
    static let queryParamDays = "days"
    static let queryParamDate = "date"
    static let queryParamLocalization = "localization"
    
    // MARK: - Query Parameter Values
    static let queryValueBitcoin = "bitcoin"
    static let queryValueFalse = "false"
    
    // MARK: - Currency Values
    static let currencyUSD = "usd"
    static let currencyEUR = "eur"
    static let currencyGBP = "gbp"
} 