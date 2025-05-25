//
//  ResponsesSpecs.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 25/5/25.
//

import Quick
import Nimble
import Foundation

@testable import N26_Bitcoin_app

class ResponsesSpecs: QuickSpec {
    override class func spec() {
        describe("SimplePriceResponse") {
            it("decodes prices dictionary correctly") {
                let json = ResponsesMocks.simplePrice
                let data = json.data(using: .utf8)!
                var response: SimplePriceResponse!
                expect {
                    response = try JSONDecoder().decode(SimplePriceResponse.self, from: data)
                }.toNot(throwError())
                expect(response.prices[.bitcoin]?[.usd]).to(equal(100.5))
                expect(response.prices[.bitcoin]?[.eur]).to(equal(90.75))
            }
        }

        describe("MarketChartResponse") {
            it("decodes prices, marketCaps, and totalVolumes correctly") {
                let json = ResponsesMocks.marketChart
                let data = json.data(using: .utf8)!
                var response: MarketChartResponse!
                expect {
                    response = try JSONDecoder().decode(MarketChartResponse.self, from: data)
                }.toNot(throwError())
                expect(response.prices.first?.timestamp).to(equal(TimeInterval(1)))
                expect(response.prices.first?.price).to(equal(2))
            }
        }

        describe("CoinHistoryResponse") {
            it("decodes current price dictionary correctly") {
                let json = ResponsesMocks.coinHistory
                let data = json.data(using: .utf8)!
                var response: CoinHistoryResponse!
                expect {
                    response = try JSONDecoder().decode(CoinHistoryResponse.self, from: data)
                }.toNot(throwError())
                expect(response.prices[.usd]).to(equal(100.0))
                expect(response.prices[.eur]).to(equal(90.0))
            }
        }
    }
} 
