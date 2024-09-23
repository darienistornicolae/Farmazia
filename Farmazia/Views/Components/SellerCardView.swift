import SwiftUI

struct SellerCardView: View {
  let seller: SellerModel

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(seller.farmName)
          .font(.headline)
          .foregroundColor(.primary)
        Spacer()
        ratingView
      }

      Text(seller.fullName)
        .font(.subheadline)
        .foregroundColor(.secondary)

      contactInfoView

      Text(seller.farmDescription)
        .font(.caption)
        .foregroundColor(.secondary)
        .lineLimit(2)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(10)
    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
  }

  private var ratingView: some View {
    HStack(spacing: 4) {
      Image(systemName: "star.fill")
        .foregroundColor(.yellow)
      Text(String(format: "%.1f", seller.rating))
        .font(.subheadline)
        .fontWeight(.bold)
    }
  }

  private var contactInfoView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Label(seller.contactInformation.email, systemImage: "envelope")
      Label(seller.contactInformation.phoneNumber, systemImage: "phone")
      Label(seller.contactInformation.addressInformation.address, systemImage: "mappin")
    }
    .font(.caption)
    .foregroundColor(.secondary)
  }
}
