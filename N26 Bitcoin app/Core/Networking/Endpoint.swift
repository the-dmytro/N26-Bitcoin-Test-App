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

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    func makeRequest() throws -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
}

struct CoinGeckoAPIConfiguration {
    let baseURL = URL(string: "https://api.coingecko.com/api/v3")!
    let defaultHeaders = ["Accept": "application/json"]
}

enum CoinGeckoEndpoint: Endpoint {
    case fetchBitcoinPrice
    case historicalPrice(days: UInt)
    case priceAtDate(date: String)
    case todayPrice

    var baseURL: URL {
        CoinGeckoAPIConfiguration().baseURL
    }

    var path: String {
        switch self {
        case .fetchBitcoinPrice:
            return "/simple/price"
        case .historicalPrice:
            return "/coins/bitcoin/market_chart"
        case .todayPrice:
            return "/coins/bitcoin/market_chart"
        case .priceAtDate:
            return "/coins/bitcoin/history"
        }
    }

    var method: HTTPMethod { .get }

    var headers: [String: String] {
        CoinGeckoAPIConfiguration().defaultHeaders
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchBitcoinPrice:
            return [
                .ids,
                .vsCurrency
            ]
        case .historicalPrice(let days):
            return [
                .vsCurrency,
                .days(days)
            ]
        case .todayPrice:
            return [
                .vsCurrency,
                .days(1)
            ]
        case .priceAtDate(let date):
            return [
                .date(date),
                .localization
            ]
        }
    }
}

fileprivate extension String {
    static let ids = "ids"
    static let vsCurrency = "vs_currency"
    static let days = "days"
    static let date = "date"
    static let localization = "localization"
    static let bitcoin = "bitcoin"
    static let usd = "usd"
    static let eur = "eur"
    static let gbp = "gbp"
    static let falseValue = "false"
}

enum Currency: String {
    case usd = "usd"
    case eur = "eur"
    case gbp = "gbp"
}

fileprivate extension URLQueryItem {
    static let ids = URLQueryItem(name: .ids, value: .bitcoin)
    
    static func vsCurrency(_ currencies: [Currency]) -> URLQueryItem {
        URLQueryItem(name: .vsCurrency, value: currencies.map(\.rawValue).joined(separator: ","))
    }
    static func days(_ days: UInt) -> URLQueryItem {
        URLQueryItem(name: .days, value: String(days))
    }
    static func date(_ date: String) -> URLQueryItem {
        URLQueryItem(name: .date, value: date)
    }
    static let localization = URLQueryItem(name: .localization, value: .falseValue)
}
