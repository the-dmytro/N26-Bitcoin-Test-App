//
//  PriceDetailView.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import SwiftUI

struct PriceDetailView: View {
    @StateObject private var viewModel: PriceDetailViewModel

    init(viewModel: PriceDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section(header: Text(viewModel.date.formatted(Date.FormatStyle().day().month().year()))) {
                PriceHistorySectionView(state: viewModel.priceLoadingState, retryAction: viewModel.retry)
            }
        }
        .navigationTitle(String.navigationTitlePriceDetail)
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}
