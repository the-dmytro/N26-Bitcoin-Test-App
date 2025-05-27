//
//  PriceHistoryView.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import SwiftUI

struct PriceHistoryView: View {
    @StateObject private var viewModel: PriceHistoryViewModel

    init(viewModel: PriceHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(String.sectionTitleCurrentPrice)) {
                    PriceHistorySectionView(state: viewModel.currentPriceState, retryAction: viewModel.retryCurrentPrice)
                }

                Section(header: Text(String.sectionTitleHistoricalPrice)) {
                    PriceHistorySectionView(state: viewModel.historicalPriceState, retryAction: viewModel.retryHistoricalPrice)
                }
            }
            .navigationTitle(String.navigationTitlePriceHistory)
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}

struct PriceHistorySectionView: View {
    let state: PriceLoadingState
    let retryAction: (() -> Void)

    var body: some View {
        switch state {
        case .notLoaded:
            EmptyView()
        case .loading:
            LoadingView()
        case .loaded(let prices):
            ForEach(prices.indices, id: \.self) { index in
                PriceHistoryViewCell(price: prices[index])
            }
        case .error(let error):
            ErrorReloadView(error: error, retryAction: retryAction)
        }
    }
}

struct PriceHistoryViewCell: View {
    let price: Price

    var body: some View {
        HStack {
            Text(String(format: .formatStringPrice, price.value))
            Spacer()
            Text(price.currency.rawValue.uppercased())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
