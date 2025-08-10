import SwiftUI

struct MarketplaceView: View {
    @EnvironmentObject private var marketplaceManager: MarketplaceManager
    @EnvironmentObject private var walletManager: WalletManager

    @State private var selectedOffer: Offer?

    var body: some View {
        NavigationStack {
            List {
                ForEach(marketplaceManager.offers) { offer in
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .overlay(Text(offer.merchantName.prefix(2)))
                        VStack(alignment: .leading) {
                            Text(offer.merchantName)
                                .font(.headline)
                            Text(offer.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(offer.costCoins)\ncoins")
                                .font(.caption)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.secondary)
                            Button("Redeem") {
                                selectedOffer = offer
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(walletManager.coins < offer.costCoins)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Marketplace")
            .sheet(item: $selectedOffer) { offer in
                RedeemView(offer: offer)
            }
        }
    }
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
            .environmentObject(MarketplaceManager())
            .environmentObject(HealthKitManager())
            .environmentObject(WalletManager())
    }
}


