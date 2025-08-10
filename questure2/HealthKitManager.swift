import Foundation
import HealthKit
import Combine

final class HealthKitManager: ObservableObject {
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var todayValidatedSteps: Int = 0

    private let healthStore = HKHealthStore()
    private var stepAnchor: HKQueryAnchor?
    private var cancellables: Set<AnyCancellable> = []

    private var calendar: Calendar { Calendar.current }

    func requestAuthorizationIfNeeded() {
        guard HKHealthStore.isHealthDataAvailable() else {
            // Simulator fallback: generate a moving step count so UI is not blank
            #if targetEnvironment(simulator)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.todayValidatedSteps = 3456
            }
            #endif
            return
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [stepType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.refreshTodaySteps()
                    self?.startObservingStepChanges()
                }
            }
        }
    }

    func startObservingStepChanges() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, _ in
            self?.refreshTodaySteps()
            completionHandler()
        }
        healthStore.execute(query)

        // Enable background delivery for near-realtime updates
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { _, _ in }
    }

    func refreshTodaySteps() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        fetchTodaySum(from: startOfDay, to: now) { [weak self] steps in
            DispatchQueue.main.async { self?.todayValidatedSteps = steps }
        }
    }

    private func fetchTodaySum(from start: Date, to end: Date, completion: @escaping (Int) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, _ in
            let total = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            completion(Int(total))
        }
        healthStore.execute(query)
    }

    // Anti-cheat filtering: ignore user-entered samples, non-Apple devices, and implausible step rates
    private func filterValidStepSamples(_ samples: [HKQuantitySample]) -> [HKQuantitySample] {
        let maxStepsPerSecond: Double = 3.5 // ~210 steps/minute, beyond elite cadence
        return samples.filter { sample in
            if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool, wasUserEntered {
                return false
            }

            if let device = sample.device {
                if device.manufacturer?.lowercased() != "apple" { return false }
                // Reject purely simulated sources
                if device.model?.lowercased().contains("simulator") == true { return false }
            }

            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            if duration > 0 {
                let rate = steps / duration
                if rate > maxStepsPerSecond { return false }
            }
            return steps > 0
        }
    }
}


