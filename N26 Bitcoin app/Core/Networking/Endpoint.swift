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

protocol RequestBuilder {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
}

extension RequestBuilder {
    func makeRequest(_ endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path += path
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

// MARK: - Endpoint Protocol

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
}

protocol APIConfiguration {
    var baseURLComponents: URLComponents { get }
    var defaultHeaders: [String: String] { get }
}

// MARK: - CoinGecko API Endpoint Configuration

struct CoinGeckoAPIConfiguration: APIConfiguration {
    let secrets: Secrets
    
    var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = .coinGeckoScheme
        components.host = .coinGeckoHost
        components.path = .coinGeckoAPIVersion
        return components
    }
    
    var defaultHeaders: [String: String] {
        [String.headerAccept: String.contentTypeJSON, String.apiKey: secrets.apiKey]
    }
}

struct CoinGeckoRequestBuilder: RequestBuilder {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]?
}

// MARK: - CoinGecko API Endpoint

enum CoinGeckoEndpoint: Endpoint {
    case historicalPrice(days: UInt, currency: Currency)
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
        case .historicalPrice(let days, let currency):
            return [
                .vsCurrency([currency]),
                .days(days)
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
                .precision(precision)
            ]
        }
    }
}

extension Date {
    func ddMMyyyyFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = .dateFormatDDMMYYYY
        return formatter.string(from: self)
    }
}

// MARK: - Private Extensions

fileprivate extension URLQueryItem {
    static let ids = URLQueryItem(name: .queryParamIds, value: .queryValueBitcoin)
    static let localization = URLQueryItem(name: .queryParamLocalization, value: .queryValueFalse)

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