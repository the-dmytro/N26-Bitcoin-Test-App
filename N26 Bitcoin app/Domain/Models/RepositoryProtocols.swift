//
//  RepositoryProtocols.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 23/5/25.
//

import Foundation

// MARK: - Core Protocols
protocol State: Equatable {}

protocol Action {}

protocol Reducer {
    associatedtype AppStateType: State
    func reduce(state: AppStateType, action: Action) -> AppStateType
}
