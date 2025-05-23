//
//  RepositoryMocks.swift
//  N26 Bitcoin appTests
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation
@testable import N26_Bitcoin_app

// MARK: - Mock State
struct MockState: State, Equatable {
    var value: Int = 0
}

// MARK: - Mock Actions
enum MockAction: Action {
    case increment
    case reset
}

// MARK: - Mock Reducer
struct MockReducer: Reducer {
    func reduce(state: MockState, action: Action) -> MockState {
        var newState = state
        switch action {
        case MockAction.increment:
            newState.value += 1
        case MockAction.reset:
            newState.value = 0
        default:
            break
        }
        return newState
    }
} 