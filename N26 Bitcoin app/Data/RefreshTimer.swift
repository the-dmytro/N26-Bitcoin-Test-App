//
//  RefreshTimer.swift
//  N26 Bitcoin app
//
//  Created by Dmytro Kopanytsia on 28/5/25.
//

import Foundation
import Combine

final class RefreshTimer {
    private let subject = PassthroughSubject<Void, Never>()
    private var timer: AnyCancellable?

    var publisher: AnyPublisher<Void, Never> {
        subject.eraseToAnyPublisher()
    }

    func start(interval: TimeInterval) {
        stop()

        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.subject.send()
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func fireOnce() {
        subject.send()
    }
}