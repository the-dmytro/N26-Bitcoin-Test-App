//
//  CurrentPriceUseCase.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 24/5/25.
//

import Foundation

struct CurrentPriceUseCase: UseCase {
    typealias Input = [Currency]
    typealias Output = Void
    typealias RepoStateType = AppState
    typealias RepoReducerType = AppReducer

    private let repository: AppRepository
    private let apiClient: APIClient

    init(repository: AppRepository, apiClient: APIClient) {
        self.repository = repository
        self.apiClient = apiClient
    }

    func execute(input: [Currency]) async -> Void {
        return ()
    }
}