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
    static let apiKey = "x-cg-demo-api-key"
    
    // MARK: - API URL Components
    static let coinGeckoScheme = "https"
    static let coinGeckoHost = "api.coingecko.com"
    static let coinGeckoAPIVersion = "/api/v3"
    
    // MARK: - API Endpoint Paths
    static let bitcoinMarketChartPath = "/coins/bitcoin/market_chart"
    static let bitcoinHistoryPath = "/coins/bitcoin/history"
    static let simplePricePath = "/simple/price"
    
    // MARK: - Query Parameter Names
    static let queryParamIds = "ids"
    static let queryParamVsCurrency = "vs_currency"
    static let queryParamDays = "days"
    static let queryParamDate = "date"
    static let queryParamLocalization = "localization"
    static let queryParamPrecision = "precision"
    static let queryParamInterval = "interval"
    static let queryParamIncludeMarketCap = "include_market_cap"
    
    // MARK: - Query Parameter Values
    static let queryValueBitcoin = "bitcoin"
    static let queryValueFalse = "false"
    static let queryValueDaily = "daily"

    // MARK: - Currency Values
    static let currencyUSD = "usd"
    static let currencyEUR = "eur"
    static let currencyGBP = "gbp"

    // MARK: – Date Formats
    static let dateFormatDDMMYYYY = "dd-MM-yyyy"

    // MARK: - View Titles
    static let sectionTitleCurrentPrice = "Current Price"
    static let sectionTitleHistoricalPrice = "Historical Price"
    static let navigationTitlePriceHistory = "Price History"
    static let navigationTitlePriceDetail = "Price Detail"

    // MARK: - Format Strings
    static let formatStringPrice = "%.2f"
} 
