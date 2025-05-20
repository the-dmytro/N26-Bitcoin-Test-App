//
//  Container.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 19/5/25.
//

import Foundation

final class Container {
    private var factories: [ObjectIdentifier: () -> Any] = [:]

    func register<Service>(_ type: Service.Type, factory: @escaping () -> Service) {
        factories[ObjectIdentifier(type)] = factory
    }

    func resolve<Service>(_ type: Service.Type = Service.self) -> Service {
        guard let factory = factories[ObjectIdentifier(type)] else {
            fatalError("No factory for \(type)")
        }
        return factory() as! Service
    }
}