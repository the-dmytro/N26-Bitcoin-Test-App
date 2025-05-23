//
//  RepositorySpecs.swift
//  N26 Bitcoin appTests
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Quick
import Nimble
import Foundation
import Combine

@testable import N26_Bitcoin_app

class RepositorySpecs: QuickSpec {
    override class func spec() {
        var repository: Repository<MockState, MockReducer>!
        var cancellables: Set<AnyCancellable>!

        beforeEach {
            repository = Repository(initialState: MockState(), reducer: MockReducer())
            cancellables = []
        }

        describe("Repository") {
            it("should have initial state") {
                expect(repository.state.value).to(equal(0))
            }

            it("should update state when dispatching actions") {
                repository.dispatch(MockAction.increment)
                expect(repository.state.value).to(equal(1))

                repository.dispatch(MockAction.increment)
                expect(repository.state.value).to(equal(2))

                repository.dispatch(MockAction.reset)
                expect(repository.state.value).to(equal(0))
            }

            context("state observing") {
                it("should emit new values when state changes") {
                    var values: [Int] = []
                    repository.observe(\.value)
                        .sink { values.append($0) }
                        .store(in: &cancellables)

                    repository.dispatch(MockAction.increment)
                    repository.dispatch(MockAction.increment)
                    repository.dispatch(MockAction.reset)

                    expect(values).to(equal([0, 1, 2, 0]))
                }
            }
        }
    }
}