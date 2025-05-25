//
//  Responses.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

struct SimplePriceResponse: Decodable {
    let prices: [Coin: [Currency: Double]]

    init(from decoder: Decoder) throws {
        let rawDict = try decoder.singleValueContainer().decode([String: [String: Double]].self)
        var result: [Coin: [Currency: Double]] = [:]

        for (coinKey, currencyDict) in rawDict {
            if let coin = Coin(rawValue: coinKey) {
                var mapped: [Currency: Double] = [:]
                for (currencyKey, value) in currencyDict {
                    if let currency = Currency(rawValue: currencyKey) {
                        mapped[currency] = value
                    }
                }
                result[coin] = mapped
            }
        }

        prices = result
    }
}

struct MarketChartResponse: Decodable {
    let prices: [PriceEntry]

    enum CodingKeys: String, CodingKey {
        case prices
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prices = try container.decode([PriceEntry].self, forKey: .prices)
    }

    struct PriceEntry: Decodable {
        let timestamp: TimeInterval
        let price: Double

        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            timestamp = try container.decode(TimeInterval.self)
            price     = try container.decode(Double.self)
        }
    }
}

struct CoinHistoryResponse: Decodable {
    let prices: [Currency: Double]

    enum CodingKeys: String, CodingKey {
        case marketData = "market_data"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let marketData = try container.decode(MarketData.self, forKey: .marketData)
        prices = marketData.currentPrice
    }

    struct MarketData: Decodable {
        let currentPrice: [Currency: Double]

        enum CodingKeys: String, CodingKey {
            case currentPrice = "current_price"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let rawPrices = try container.nestedContainer(keyedBy: DynamicKey.self, forKey: .currentPrice)

            var dict: [Currency: Double] = [:]
            for key in rawPrices.allKeys {
                if let currency = Currency(rawValue: key.stringValue) {
                    let value = try rawPrices.decode(Double.self, forKey: key)
                    dict[currency] = value
                }
            }
            currentPrice = dict
        }

        private struct DynamicKey: CodingKey {
            let stringValue: String
            init?(stringValue: String) { self.stringValue = stringValue }
            var intValue: Int? { nil }
            init?(intValue: Int) { return nil }
        }
    }
}
