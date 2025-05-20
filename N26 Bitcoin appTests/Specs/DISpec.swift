//
//  DISpec.swift
//  N26 Bitcoin appTests
//
//  Created by Dmytro Kopanytsia on 20/5/25.
//

import Quick
import Nimble

@testable import N26_Bitcoin_app

class DISpec: QuickSpec {
    override class func spec() {
        var container: Container!

        beforeEach {
            container = Container()
        }

        describe("resolving services") {
            it("should be able to resolve a registered service") {
                let testService = "test"

                container.register(String.self, factory: { testService })

                let service = container.resolve(String.self)

                expect(service).to(equal(testService))
            }
            
            it("should fail to resolve an unregistered service") {
                expect {
                    _ = container.resolve(String.self)
                }.to(throwAssertion())
            }

            it("should overwrite previous registration of the same type") {
                let testService = "test"
                let anotherTestService = "another test"

                container.register(String.self, factory: { testService })
                container.register(String.self, factory: { anotherTestService })

                let service = container.resolve(String.self)

                expect(service).to(equal(anotherTestService))
            }

            it("shouldn't overwrite registration of different types") {
                let testStringService = "test"
                let testIntService = 1

                container.register(String.self, factory: { testStringService })
                container.register(Int.self, factory: { testIntService })

                let stringService = container.resolve(String.self)
                let intService = container.resolve(Int.self)

                expect(stringService).to(equal(testStringService))
                expect(intService).to(equal(testIntService))
            }

            it("should invoke the factory closure each time a service is resolved") {
                var factoryInvocations = 0
                let factory = {
                    factoryInvocations += 1
                    return factoryInvocations
                }

                container.register(Int.self, factory: factory)

                _ = container.resolve(Int.self)
                _ = container.resolve(Int.self)

                expect(factoryInvocations).to(equal(2))
            }
        }
    }
}
