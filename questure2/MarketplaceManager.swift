import Foundation

final class MarketplaceManager: ObservableObject {
    @Published var offers: [Offer] = [
        Offer(merchantName: "Joe's Juice", title: "20% off", costCoins: 200),
        Offer(merchantName: "Yummy Eats", title: "15% off", costCoins: 150)
    ]
}


