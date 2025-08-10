import SwiftUI

struct WalletView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var healthManager: HealthKitManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Label("Coins", systemImage: "bitcoinsign.circle")
                    Spacer()
                    Text("\(walletManager.coins)")
                        .font(.title)
                        .bold()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))

                HStack(spacing: 16) {
                    Label("Steps Today", systemImage: "figure.walk")
                    Spacer()
                    Text("\(healthManager.todayValidatedSteps)")
                        .font(.title2)
                        .bold()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))

                if let updated = walletManager.lastUpdated {
                    Text("Updated: \(updated.formatted(date: .omitted, time: .standard))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Wallet")
            .onAppear {
                walletManager.bind(to: healthManager)
                // Ensure we refresh when the wallet comes into view
                healthManager.refreshTodaySteps()
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
            .environmentObject(WalletManager())
            .environmentObject(MarketplaceManager())
            .environmentObject(HealthKitManager())
    }
}


