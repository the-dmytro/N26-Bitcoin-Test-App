//
//  Assembly.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

protocol Assembly {
    @MainActor
    func assemble(into container: Container)
}

struct SecretsAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        let secrets: Secrets = CoinGeckoSecrets()
        container.register(Secrets.self) { secrets }
    }
}

struct APIConfigurationAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        container.register(APIConfiguration.self) { CoinGeckoAPIConfiguration(secrets: container.resolve()) }
    }
}

struct NetworkAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        container.register(APIClient.self) { URLSessionAPIClient() }
    }
}

struct RepositoryAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        let repository: AppRepository = Repository(initialState: AppState(), reducer: AppReducer())
        container.register(AppRepository.self) {
            repository
        }
    }
}

struct UseCaseAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        container.register(DayPriceUseCase.self) {
            DayPriceUseCase(repository: container.resolve(), apiClient: container.resolve())
        }
        container.register(HistoricalPriceUseCase.self) {
            HistoricalPriceUseCase(repository: container.resolve(), apiClient: container.resolve())
        }
        container.register(CurrentPriceUseCase.self) {
            CurrentPriceUseCase(repository: container.resolve(), apiClient: container.resolve())
        }
    }
}

struct RootAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        SecretsAssembly().assemble(into: container)
        APIConfigurationAssembly().assemble(into: container)
        NetworkAssembly().assemble(into: container)
        RepositoryAssembly().assemble(into: container)
        UseCaseAssembly().assemble(into: container)
    }
}