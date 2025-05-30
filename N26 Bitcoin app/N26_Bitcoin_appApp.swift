//
//  N26_Bitcoin_appApp.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import SwiftUI

@main
struct N26_Bitcoin_appApp: App {
    let container: Container = {
        let container = Container()
        RootAssembly().assemble(into: container)
        return container
    }()

    var body: some Scene {
        WindowGroup {
            PriceHistoryView()
        }
        .environment(\.container, container)
    }
}
