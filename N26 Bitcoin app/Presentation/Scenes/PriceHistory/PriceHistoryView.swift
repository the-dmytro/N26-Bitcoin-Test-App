//
//  PriceHistoryView.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import SwiftUI

struct PriceHistoryView: View {
    @Environment(\.container) private var container

    var body: some View {
        PriceHistoryContentView(viewModel: container.resolve())
    }
}

struct PriceHistoryContentView: View {
    @StateObject private var viewModel: PriceHistoryViewModel

    init(viewModel: PriceHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: PriceDetailView(date: viewModel.selectedDate ?? Date()),
                               isActive: .constant(viewModel.selectedDate != nil)) {
                    EmptyView()
                }

                List {
                    PriceHistorySectionView(title: String.sectionTitleCurrentPrice,
                                            state: viewModel.currentPriceState,
                                            retryAction: viewModel.retryCurrentPrice,
                                            selectAction: nil)

                    PriceHistorySectionView(title: String.sectionTitleHistoricalPrice,
                                            state: viewModel.historicalPriceState,
                                            retryAction: viewModel.retryHistoricalPrice,
                                            selectAction: { viewModel.selectHistoricalPrice(at: $0) })
                }
                .navigationTitle(String.navigationTitlePriceHistory)
                .listStyle(.insetGrouped)
            }
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}

struct PriceHistorySectionView: View {
    let title: String
    let state: PriceLoadingState
    let retryAction: (() -> Void)
    let selectAction: ((Int) -> Void)?

    var body: some View {
        Section(header: Text(title)) {
            switch state {
            case .notLoaded:
                EmptyView()
            case .loading:
                LoadingView()
            case .loaded(let prices):
                ForEach(prices.indices, id: \.self) { index in
                    PriceHistoryViewCell(price: prices[index],
                                         action: { selectAction?(index) })
                }
            case .error(let error):
                ErrorReloadView(error: error, retryAction: retryAction)
            }
        }
    }
}

struct PriceHistoryViewCell: View {
    let price: Price
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(String(format: .formatStringPrice, price.value))
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(price.currency.rawValue.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
