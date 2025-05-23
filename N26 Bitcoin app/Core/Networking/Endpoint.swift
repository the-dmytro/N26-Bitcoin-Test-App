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
        guard let baseURL = CoinGeckoAPIConfiguration().baseURLComponents.url else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path += path  // Now properly appends to /api/v3
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
    var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = .coinGeckoScheme
        components.host = .coinGeckoHost
        components.path = .coinGeckoAPIVersion
        return components
    }
    
    let defaultHeaders = [String.headerAccept: String.contentTypeJSON]
}

enum CoinGeckoEndpoint: Endpoint {
    case historicalPrice(days: UInt, currencies: [Currency])
    case priceAtDate(date: String)
    case todayPrice(currencies: [Currency])
    case currentPrice(currencies: [Currency])

    var baseURL: URL {
        guard let url = CoinGeckoAPIConfiguration().baseURLComponents.url else {
            fatalError("Invalid base URL configuration")
        }
        return url
    }

    var path: String {
        switch self {
        case .historicalPrice:
            return "/coins/bitcoin/market_chart"
        case .todayPrice:
            return "/coins/bitcoin/market_chart"
        case .priceAtDate:
            return "/coins/bitcoin/history"
        case .currentPrice:
            return "/simple/price"
        }
    }

    var method: HTTPMethod { .get }

    var headers: [String: String] {
        CoinGeckoAPIConfiguration().defaultHeaders
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .historicalPrice(let days, let currencies):
            return [
                .vsCurrency(currencies),
                .days(days)
            ]
        case .todayPrice(let currencies):
            return [
                .vsCurrency(currencies),
                .days(1)
            ]
        case .priceAtDate(let date):
            return [
                .date(date),
                .localization
            ]
        case .currentPrice(let currencies):
            return [
                .ids,
                .vsCurrency(currencies)
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
