//
//  NetworkingSpecs.swift
//  N26 Bitcoin appTests
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Quick
import Nimble
import Foundation

@testable import N26_Bitcoin_app

class NetworkingSpecs: QuickSpec {
    override class func spec() {
        describe("HTTPMethod") {
            it("should have correct raw values") {
                expect(HTTPMethod.get.rawValue).to(equal(.httpMethodGET))
            }
        }
        
        describe("Currency") {
            it("should have correct raw values") {
                expect(Currency.usd.rawValue).to(equal(.currencyUSD))
                expect(Currency.eur.rawValue).to(equal(.currencyEUR))
                expect(Currency.gbp.rawValue).to(equal(.currencyGBP))
            }
        }
        
        describe("CoinGeckoAPIConfiguration") {
            let config = CoinGeckoAPIConfiguration()
            
            it("should have correct base URL") {
                expect(config.baseURL.absoluteString).to(equal(.coinGeckoBaseURL))
            }
            
            it("should have correct default headers") {
                expect(config.defaultHeaders[.headerAccept]).to(equal(.contentTypeJSON))
            }
        }
        
        describe("CoinGeckoEndpoint") {
            let currencies: [Currency] = [.usd, .eur, .gbp]
            
            describe("historicalPrice") {
                let endpoint = CoinGeckoEndpoint.historicalPrice(days: 7, currencies: currencies)
                
                it("should have correct base URL") {
                    expect(endpoint.baseURL.absoluteString).to(equal(.coinGeckoBaseURL))
                }
                
                it("should have correct path") {
                    expect(endpoint.path).to(equal(.bitcoinMarketChartPath))
                }
                
                it("should have GET method") {
                    expect(endpoint.method).to(equal(.get))
                }
                
                it("should have correct headers") {
                    expect(endpoint.headers[.headerAccept]).to(equal(.contentTypeJSON))
                }
                
                it("should have correct query items") {
                    let queryItems = endpoint.queryItems
                    expect(queryItems).toNot(beNil())
                    expect(queryItems?.count).to(equal(2))
                    
                    let vsCurrencyItem = queryItems?.first { $0.name == .queryParamVsCurrency }
                    expect(vsCurrencyItem?.value).to(equal("usd,eur,gbp"))
                    
                    let daysItem = queryItems?.first { $0.name == .queryParamDays }
                    expect(daysItem?.value).to(equal("7"))
                }
            }
            
            describe("todayPrice") {
                let endpoint = CoinGeckoEndpoint.todayPrice(currencies: currencies)
                
                it("should have correct path") {
                    expect(endpoint.path).to(equal(.bitcoinMarketChartPath))
                }
                
                it("should have correct query items with 1 day") {
                    let queryItems = endpoint.queryItems
                    expect(queryItems).toNot(beNil())
                    
                    let daysItem = queryItems?.first { $0.name == .queryParamDays }
                    expect(daysItem?.value).to(equal("1"))
                }
            }
            
            describe("priceAtDate") {
                let endpoint = CoinGeckoEndpoint.priceAtDate(date: .testDate, currencies: currencies)
                
                it("should have correct path") {
                    expect(endpoint.path).to(equal(.bitcoinHistoryPath))
                }
                
                it("should have correct query items") {
                    let queryItems = endpoint.queryItems
                    expect(queryItems).toNot(beNil())
                    expect(queryItems?.count).to(equal(3))
                    
                    let dateItem = queryItems?.first { $0.name == .queryParamDate }
                    expect(dateItem?.value).to(equal(.testDate))
                    
                    let localizationItem = queryItems?.first { $0.name == .queryParamLocalization }
                    expect(localizationItem?.value).to(equal(.queryValueFalse))
                    
                    let vsCurrencyItem = queryItems?.first { $0.name == .queryParamVsCurrency }
                    expect(vsCurrencyItem?.value).to(equal("usd,eur,gbp"))
                }
            }
        }
        
        describe("Endpoint makeRequest()") {
            let endpoint = CoinGeckoEndpoint.historicalPrice(days: 7, currencies: [.usd])
            
            it("should create a valid URLRequest") {
                expect {
                    let request = try endpoint.makeRequest()
                    expect(request.httpMethod).to(equal(.httpMethodGET))
                    expect(request.url?.absoluteString).to(contain(.coinGeckoBaseURL + .bitcoinMarketChartPath))
                    expect(request.url?.absoluteString).to(contain(.queryParamVsCurrency + "=" + .currencyUSD))
                    expect(request.url?.absoluteString).to(contain(.queryParamDays + "=7"))
                    expect(request.allHTTPHeaderFields?[.headerAccept]).to(equal(.contentTypeJSON))
                }.toNot(throwError())
            }
            
            it("should return a request with correct URL components") {
                do {
                    let request = try endpoint.makeRequest()
                    let url = request.url
                    expect(url?.scheme).to(equal("https"))
                    expect(url?.host).to(equal("api.coingecko.com"))
                    expect(url?.path).to(equal("/api/v3" + .bitcoinMarketChartPath))
                } catch {
                    fail("makeRequest should not throw: \(error)")
                }
            }
        }
        
        describe("URLSessionAPIClient") {
            var apiClient: URLSessionAPIClient!
            var mockEndpoint: MockEndpoint!
            
            beforeEach {
                apiClient = URLSessionAPIClient()
                mockEndpoint = MockEndpoint()
            }
            
            describe("send(_:)") {
                context("when endpoint throws an error during request creation") {
                    it("should return networkError") {
                        mockEndpoint.shouldFailOnMakeRequest = true
                        
                        waitUntil { done in
                            Task {
                                let result: Result<MockResponse, APIError> = await apiClient.send(mockEndpoint)
                                
                                expect(result).to(beFailure())
                                guard case .failure(let error) = result else {
                                    fail("Expected failure but got success")
                                    return
                                }
                                expect(error).to(beAKindOf(APIError.self))
                                if case APIError.networkError = error {
                                    // Success - this is what we expected
                                } else {
                                    fail("Expected networkError but got \(error)")
                                }
                                done()
                            }
                        }
                    }
                    
                    it("should return the correct error type when endpoint creation fails") {
                        mockEndpoint.shouldFailOnMakeRequest = true
                        
                        waitUntil { done in
                            Task {
                                let result: Result<MockResponse, APIError> = await apiClient.send(mockEndpoint)
                                
                                expect(result).to(beFailure())
                                guard case .failure(let error) = result else {
                                    fail("Expected failure but got success")
                                    return
                                }
                                expect(error).to(beAKindOf(APIError.self))
                                if case APIError.networkError = error {
                                    // Success - this is what we expected
                                } else {
                                    fail("Expected networkError but got \(error)")
                                }
                                done()
                            }
                        }
                    }
                }
            }
        }
        
        describe("APIError") {
            it("should have correct cases") {
                let invalidResponse = APIError.invalidResponse
                let decodingError = APIError.decodingError(NSError(domain: .testErrorDomain, code: 1))
                let networkError = APIError.networkError(NSError(domain: .testErrorDomain, code: 2))
                
                expect(invalidResponse).to(beAKindOf(APIError.self))
                expect(decodingError).to(beAKindOf(APIError.self))
                expect(networkError).to(beAKindOf(APIError.self))
            }
        }
    }
} 