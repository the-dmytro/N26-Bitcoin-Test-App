//
//  Endpoint.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET" // There is only GET in use, add other methods if needed
}

// MARK: - Endpoint Protocol

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    func makeRequest() throws -> URLRequest {
        guard let baseURL = CoinGeckoAPIConfiguration().baseURLComponents.url else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.path += path
        components.queryItems = queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 10
        request.httpShouldHandleCookies = false
        return request
    }
}

// MARK: - CoinGecko API Endpoint Configuration

struct CoinGeckoAPIConfiguration {
    var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = .coinGeckoScheme
        components.host = .coinGeckoHost
        components.path = .coinGeckoAPIVersion
        return components
    }
    
    var defaultHeaders: [String: String] {
        [
            String.headerAccept.lowercased(): String.contentTypeJSON,
            String.apiKey: Secrets.apiKey
        ]
    }
}

// MARK: - CoinGecko API Endpoint

enum CoinGeckoEndpoint: Endpoint {
    case historicalPrice(days: UInt, currency: Currency, precision: Int)
    case priceAtDate(date: Date)
    case currentPrice(currencies: [Currency], precision: Int)

    var baseURL: URL {
        guard let url = CoinGeckoAPIConfiguration().baseURLComponents.url else {
            fatalError("Invalid base URL configuration")
        }
        return url
    }

    var path: String {
        switch self {
        case .historicalPrice:
            return .bitcoinMarketChartPath
        case .priceAtDate:
            return .bitcoinHistoryPath
        case .currentPrice:
            return .simplePricePath
        }
    }

    var method: HTTPMethod { .get }

    var headers: [String: String] {
        CoinGeckoAPIConfiguration().defaultHeaders
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .historicalPrice(let days, let currency, let precision):
            return [
                .vsCurrency([currency]),
                .days(days),
                .interval,
                .precision(precision)
            ]
        case .priceAtDate(let date):
            return [
                .date(date),
                .localization
            ]
        case .currentPrice(let currencies, let precision):
            return [
                .ids,
                .vsCurrency(currencies),
                .precision(precision),
                .includeMarketCap
            ]
        }
    }
}

// MARK: - Private Extensions

fileprivate extension URLQueryItem {
    static let ids = URLQueryItem(name: .queryParamIds, value: .queryValueBitcoin)
    static let localization = URLQueryItem(name: .queryParamLocalization, value: .queryValueFalse)
    static let interval = URLQueryItem(name: .queryParamInterval, value: .queryValueDaily)
    static let includeMarketCap = URLQueryItem(name: .queryParamIncludeMarketCap, value: .queryValueFalse)

    static func vsCurrency(_ currencies: [Currency]) -> URLQueryItem {
        URLQueryItem(name: .queryParamVsCurrency, value: currencies.map(\.rawValue).joined(separator: ","))
    }
    static func days(_ days: UInt) -> URLQueryItem {
        URLQueryItem(name: .queryParamDays, value: String(days))
    }
    static func date(_ date: Date) -> URLQueryItem {
        URLQueryItem(name: .queryParamDate, value: date.ddMMyyyyFormat())
    }
    static func precision(_ precision: Int) -> URLQueryItem {
        URLQueryItem(name: .queryParamPrecision, value: String(precision))
    }
}

extension Date {
    func ddMMyyyyFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = .dateFormatDDMMYYYY
        return formatter.string(from: self)
    }
}
