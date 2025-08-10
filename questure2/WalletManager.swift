import Foundation
import Combine

final class WalletManager: ObservableObject {
    @Published private(set) var coins: Int = 0
    @Published private(set) var lifetimeSteps: Int = 0
    @Published private(set) var lastUpdated: Date? = nil

    private var cancellables: Set<AnyCancellable> = []

    init() {}

    func bind(to healthManager: HealthKitManager) {
        healthManager.$todayValidatedSteps
            .receive(on: DispatchQueue.main)
            .sink { [weak self] steps in
                self?.lifetimeSteps = steps
                self?.coins = Self.convertStepsToCoins(steps)
                self?.lastUpdated = Date()
            }
            .store(in: &cancellables)
    }

    static func convertStepsToCoins(_ steps: Int) -> Int {
        // Example rate: 100 steps = 1 coin
        return steps / 100
    }
}


