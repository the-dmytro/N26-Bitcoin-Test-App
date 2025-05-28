//
//  PriceDetailView.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import SwiftUI

struct PriceDetailView: View {
    @Environment(\.container) private var container

    let date: Date
    
    var body: some View {
        PriceDetailContentView(date: date, viewModel: container.resolve())
    }
}

struct PriceDetailContentView: View {
    @StateObject private var viewModel: PriceDetailViewModel

    let date: Date

    init(date: Date, viewModel: PriceDetailViewModel) {
        self.date = date
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            PriceHistorySectionView(title: viewModel.selectedDateText,
                                    state: viewModel.priceLoadingState,
                                    retryAction: viewModel.retry,
                                    selectAction: nil)
        }
        .navigationTitle(String.navigationTitlePriceDetail)
        .onAppear {
            viewModel.loadPrice(for: date)
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}
