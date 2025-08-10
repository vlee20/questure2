//
//  questure2App.swift
//  questure2
//
//  Created by Vincent Lee on 8/10/25.
//

import SwiftUI

@main
struct questure2App: App {
    @StateObject private var healthManager = HealthKitManager()
    @StateObject private var walletManager = WalletManager()
    @StateObject private var marketplaceManager = MarketplaceManager()
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
                .environmentObject(walletManager)
                .environmentObject(marketplaceManager)
                .environmentObject(authManager)
        }
    }
}
