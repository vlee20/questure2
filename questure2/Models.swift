import Foundation

struct Offer: Identifiable, Hashable {
    let id: UUID = UUID()
    let merchantName: String
    let title: String
    let costCoins: Int
}


