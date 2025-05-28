//
//  ContainerKey.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import SwiftUI

struct ContainerKey: EnvironmentKey {
    static var defaultValue = Container()
}

extension EnvironmentValues {
    var container: Container {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}
