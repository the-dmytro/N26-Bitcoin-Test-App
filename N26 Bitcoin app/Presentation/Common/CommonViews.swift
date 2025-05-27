//
//  CommonViews.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 27/5/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

struct ErrorReloadView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        Button {
            retryAction()
        } label: {
            HStack {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                Spacer()
                Image.refresh
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            retryAction()
        }
    }
}