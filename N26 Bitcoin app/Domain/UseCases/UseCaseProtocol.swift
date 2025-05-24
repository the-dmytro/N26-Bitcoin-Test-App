//
//  UseCaseProtocol.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 24/5/25.
//

import Foundation

protocol UseCase {
    associatedtype Input
    associatedtype Output
    associatedtype RepoStateType: State
    associatedtype RepoReducerType: Reducer where RepoReducerType.AppStateType == RepoStateType

    func execute(input: Input) async -> Output
}