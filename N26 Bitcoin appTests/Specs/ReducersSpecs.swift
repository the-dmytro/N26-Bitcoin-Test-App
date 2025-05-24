//
//  ReducersSpecs.swift
//  N26 Bitcoin appTests
//
//  Created by Dmytro Kopanytsia on 25/5/25.
//

import Quick
import Nimble
import Foundation

@testable import N26_Bitcoin_app

class ReducersSpecs: QuickSpec {
    override class func spec() {
        describe("HistoricalPriceReducer") {
            let reducer = HistoricalPriceReducer()
            var state: HistoricalPriceState!

            beforeEach {
                state = HistoricalPriceState()
            }

            it("sets loadingState to loading on load action") {
                let newState = reducer.reduce(state: state, action: HistoricalPriceAction.load(days: 7, currencies: [.usd]))
                expect(newState.loadingState).to(equal(LoadingState.loading))
            }

            it("updates prices and sets loadingState to success on success action") {
                let prices = [Price(value: 1.0, currency: .usd)]
                let newState = reducer.reduce(state: state, action: HistoricalPriceAction.success(prices: prices))
                expect(newState.prices).to(equal(prices))
                expect(newState.loadingState).to(equal(LoadingState.loaded))
            }

            it("sets loadingState to failure on failure action") {
                let expectedError = MockError.test
                let newState = reducer.reduce(state: state, action: HistoricalPriceAction.failure(expectedError))
                expect(newState.loadingState).to(equal(LoadingState.loadingError(expectedError)))
            }
        }

        describe("CurrentPriceReducer") {
            let reducer = CurrentPriceReducer()
            var state: CurrentPriceState!

            beforeEach {
                state = CurrentPriceState()
            }

            it("sets loadingState to loading on load action") {
                let newState = reducer.reduce(state: state, action: CurrentPriceAction.load(currencies: [.usd]))
                expect(newState.loadingState).to(equal(LoadingState.loading))
            }

            it("updates price and sets loadingState to success on success action") {
                let price = Price(value: 2.0, currency: .eur)
                let newState = reducer.reduce(state: state, action: CurrentPriceAction.success(price: price))
                expect(newState.price).to(equal(price))
                expect(newState.loadingState).to(equal(LoadingState.loaded))
            }

            it("sets loadingState to failure on failure action") {
                let expectedError = MockError.test
                let newState = reducer.reduce(state: state, action: CurrentPriceAction.failure(expectedError))
                expect(newState.loadingState).to(equal(LoadingState.loadingError(expectedError)))
            }
        }

        describe("SelectedDayPriceReducer") {
            let reducer = SelectedDayPriceReducer()
            var state: SelectedDayPriceState!

            beforeEach {
                state = SelectedDayPriceState()
            }

            it("sets loadingState to loading and updates date on select action") {
                let date = Date()
                let newState = reducer.reduce(state: state, action: SelectedDayPriceAction.select(date: date))
                expect(newState.loadingState).to(equal(LoadingState.loading))
                expect(newState.date).to(equal(date))
            }

            it("updates prices and sets loadingState to success on success action") {
                let prices = [Price(value: 3.0, currency: .gbp)]
                let newState = reducer.reduce(state: state, action: SelectedDayPriceAction.success(prices: prices))
                expect(newState.prices).to(equal(prices))
                expect(newState.loadingState).to(equal(LoadingState.loaded))
            }

            it("sets loadingState to failure on failure action") {
                let expectedError = MockError.test
                let newState = reducer.reduce(state: state, action: SelectedDayPriceAction.failure(expectedError))
                expect(newState.loadingState).to(equal(LoadingState.loadingError(expectedError)))
            }
        }

        describe("AppReducer") {
            let reducer = AppReducer()
            var appState: AppState!

            beforeEach {
                appState = AppState()
            }

            it("forwards HistoricalPriceAction to HistoricalPriceReducer") {
                let testDays: UInt = 5
                let testCurrencies: [Currency] = [.eur]
                let newState = reducer.reduce(state: appState, action: HistoricalPriceAction.load(days: testDays, currencies: testCurrencies))
                expect(newState.historicalPrice.loadingState).to(equal(LoadingState.loading))
                expect(newState.currentPrice.loadingState).to(equal(LoadingState.notLoaded)) // Assuming initial state is .idle
                expect(newState.selectedDay.loadingState).to(equal(LoadingState.notLoaded))
            }

            it("forwards CurrentPriceAction to CurrentPriceReducer") {
                let price = Price(value: 4.0, currency: .usd)
                let newState = reducer.reduce(state: appState, action: CurrentPriceAction.success(price: price))
                expect(newState.currentPrice.price).to(equal(price))
                expect(newState.currentPrice.loadingState).to(equal(LoadingState.loaded))
                expect(newState.historicalPrice.loadingState).to(equal(LoadingState.notLoaded))
                expect(newState.selectedDay.loadingState).to(equal(LoadingState.notLoaded))
            }

            it("forwards SelectedDayPriceAction to SelectedDayPriceReducer") {
                let date = Date(timeIntervalSince1970: 1000)
                let newState = reducer.reduce(state: appState, action: SelectedDayPriceAction.select(date: date))
                expect(newState.selectedDay.date).to(equal(date))
                expect(newState.selectedDay.loadingState).to(equal(LoadingState.loading))
                expect(newState.historicalPrice.loadingState).to(equal(LoadingState.notLoaded))
                expect(newState.currentPrice.loadingState).to(equal(LoadingState.notLoaded))
            }
        }
    }
}
