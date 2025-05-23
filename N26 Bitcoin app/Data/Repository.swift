//
//  Repository.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation
import Combine

// MARK: - Repository
@MainActor
class Repository<AppStateType: State, AppReducerType: Reducer>: ObservableObject where AppReducerType.AppStateType == AppStateType {
    @Published private(set) var state: AppStateType
    
    private let reducer: AppReducerType
    private var cancellables = Set<AnyCancellable>()
    
    init(initialState: AppStateType, reducer: AppReducerType) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func dispatch(_ action: Action) {
        let newState = reducer.reduce(state: state, action: action)
        state = newState
    }
}

// MARK: - State Observing
extension Repository {
    func observe<T>(_ keyPath: KeyPath<AppStateType, T>) -> AnyPublisher<T, Never> where T: Equatable {
        return $state
            .map(keyPath)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
