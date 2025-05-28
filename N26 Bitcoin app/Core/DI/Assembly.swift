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

struct ServicesAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        container.register(RefreshTimer.self) { RefreshTimer() }
    }
}

struct ViewModelAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        container.register(PriceHistoryViewModel.self) {
            PriceHistoryViewModel(repository: container.resolve(),
                                  historicalPriceUseCase: container.resolve(),
                                  currentPriceUseCase: container.resolve(),
                                  selectedDayUseCase: container.resolve(),
                                  refreshTimer: container.resolve())
        }
        container.register(PriceDetailViewModel.self) {
            PriceDetailViewModel(repository: container.resolve(),
                                 priceUseCase: container.resolve())
        }
    }
}

struct RootAssembly: Assembly {
    @MainActor
    func assemble(into container: Container) {
        NetworkAssembly().assemble(into: container)
        RepositoryAssembly().assemble(into: container)
        UseCaseAssembly().assemble(into: container)
        ServicesAssembly().assemble(into: container)
        ViewModelAssembly().assemble(into: container)
    }
}