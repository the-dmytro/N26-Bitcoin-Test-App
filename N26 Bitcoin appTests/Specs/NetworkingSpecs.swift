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
        
        describe("CoinGeckoAPIConfiguration") {
            let config = CoinGeckoAPIConfiguration()
            
            it("should have correct base URL components") {
                let expectedURL = "\(String.coinGeckoScheme)://\(String.coinGeckoHost)\(String.coinGeckoAPIVersion)"
                expect(config.baseURLComponents.url?.absoluteString).to(equal(expectedURL))
            }
            
            it("should have correct scheme") {
                expect(config.baseURLComponents.scheme).to(equal(.coinGeckoScheme))
            }
            
            it("should have correct host") {
                expect(config.baseURLComponents.host).to(equal(.coinGeckoHost))
            }
            
            it("should have correct API version path") {
                expect(config.baseURLComponents.path).to(equal(.coinGeckoAPIVersion))
            }
            
            it("should have correct default headers") {
                expect(config.defaultHeaders[.headerAccept]).to(equal(.contentTypeJSON))
            }
            
            it("should create valid URL from components") {
                expect(config.baseURLComponents.url).toNot(beNil())
            }
        }
        
        describe("CoinGeckoEndpoint") {
            let currencies: [Currency] = [.usd, .eur, .gbp]
            
            describe("historicalPrice") {
                let endpoint = CoinGeckoEndpoint.historicalPrice(days: 7, currencies: currencies)
                
                it("should have correct base URL") {
                    let expectedURL = "\(String.coinGeckoScheme)://\(String.coinGeckoHost)\(String.coinGeckoAPIVersion)"
                    expect(endpoint.baseURL.absoluteString).to(equal(expectedURL))
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
                let endpoint = CoinGeckoEndpoint.priceAtDate(date: .testDate)
                
                it("should have correct path") {
                    expect(endpoint.path).to(equal(.bitcoinHistoryPath))
                }
                
                it("should have correct query items") {
                    let queryItems = endpoint.queryItems
                    expect(queryItems).toNot(beNil())
                    expect(queryItems?.count).to(equal(2))
                    
                    let dateItem = queryItems?.first { $0.name == .queryParamDate }
                    expect(dateItem?.value).to(equal(.testDate))
                    
                    let localizationItem = queryItems?.first { $0.name == .queryParamLocalization }
                    expect(localizationItem?.value).to(equal(.queryValueFalse))
                }
            }
            
            describe("currentPrice") {
                let endpoint = CoinGeckoEndpoint.currentPrice(currencies: currencies)
                
                it("should have correct path") {
                    expect(endpoint.path).to(equal(.simplePricePath))
                }
                
                it("should have correct query items") {
                    let queryItems = endpoint.queryItems
                    expect(queryItems).toNot(beNil())
                    expect(queryItems?.count).to(equal(2))
                    
                    let idsItem = queryItems?.first { $0.name == .queryParamIds }
                    expect(idsItem?.value).to(equal(.queryValueBitcoin))
                    
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
                    
                    let expectedBaseURL = "\(String.coinGeckoScheme)://\(String.coinGeckoHost)\(String.coinGeckoAPIVersion)\(String.bitcoinMarketChartPath)"
                    expect(request.url?.absoluteString).to(contain(expectedBaseURL))
                    expect(request.url?.absoluteString).to(contain(.queryParamVsCurrency + "=" + .currencyUSD))
                    expect(request.url?.absoluteString).to(contain(.queryParamDays + "=7"))
                    expect(request.allHTTPHeaderFields?[.headerAccept]).to(equal(.contentTypeJSON))
                }.toNot(throwError())
            }
            
            it("should return a request with correct URL components") {
                do {
                    let request = try endpoint.makeRequest()
                    let url = request.url
                    expect(url?.scheme).to(equal(.coinGeckoScheme))
                    expect(url?.host).to(equal(.coinGeckoHost))
                    expect(url?.path).to(equal(.coinGeckoAPIVersion + .bitcoinMarketChartPath))
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
                                
                                switch error {
                                case .networkError:
                                    break
                                case .invalidResponse:
                                    fail("Expected networkError but got invalidResponse")
                                case .decodingError:
                                    fail("Expected networkError but got decodingError")
                                }
                                done()
                            }
                        }
                    }
                }
            }
        }
    }
} 
