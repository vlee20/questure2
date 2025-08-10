//
//  ContentView.swift
//  questure2
//
//  Created by Vincent Lee on 8/10/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var healthManager: HealthKitManager
    @EnvironmentObject private var marketplaceManager: MarketplaceManager
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        TabView {
            WalletView()
                .tabItem {
                    Image(systemName: "wallet.pass")
                    Text("Wallet")
                }

            MarketplaceView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Marketplace")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .onAppear {
            healthManager.requestAuthorizationIfNeeded()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager())
        .environmentObject(WalletManager())
        .environmentObject(MarketplaceManager())
        .environmentObject(AuthManager())
}
