import SwiftUI
import CoreImage.CIFilterBuiltins

struct RedeemView: View {
    let offer: Offer
    @Environment(\.dismiss) private var dismiss

    private var qrString: String {
        "OFFER:\(offer.merchantName)|\(offer.title)|\(offer.costCoins)|\(UUID().uuidString)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(Text(offer.merchantName.prefix(2)))
                    VStack(alignment: .leading) {
                        Text(offer.merchantName).font(.headline)
                        Text(offer.title).font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                }

                Text("\(offer.costCoins) RunCoins")

                QRCodeView(text: qrString)
                    .frame(width: 220, height: 220)

                Text(UUID().uuidString.prefix(10))
                    .font(.headline)
                    .monospaced()

                Spacer()

                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Redeem")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct QRCodeView: View {
    let text: String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        if let image = generateQRCode(from: text) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Color.gray
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 8, y: 8)),
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }
        return nil
    }
}


