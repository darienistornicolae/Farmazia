import SwiftUI

struct ProductCardView: View {
  let product: ProductModel
  let addToCart: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      AsyncImage(url: URL(string: product.image ?? "")) { image in
        image.resizable().aspectRatio(contentMode: .fill)
      } placeholder: {
        Color.gray
      }
      .frame(width: 100, height: 100)
      .clipShape(RoundedRectangle(cornerRadius: 8))

      VStack(alignment: .leading, spacing: 4) {
        Text(product.name)
          .font(.headline)
          .lineLimit(1)

        Text("$\(String(format: "%.2f", product.price))")
          .font(.subheadline)

        HStack {
          Text(product.isOutOfStock ? "Out of Stock" : "In Stock")
            .font(.caption)
            .foregroundColor(product.isOutOfStock ? .red : .green)

          if product.isOrganic {
            Text("Organic")
              .font(.caption)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.green.opacity(0.2))
              .cornerRadius(4)
          }
        }

        Text(product.productType.description)
          .font(.caption)
          .foregroundColor(.blue)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      VStack {
        Spacer()
        Button(action: addToCart) {
          Image(systemName: "cart.badge.plus")
            .foregroundColor(.white)
            .padding(8)
            .background(product.isOutOfStock ? Color.gray : Color.green)
            .clipShape(Circle())
        }
        .disabled(product.isOutOfStock)
      }
    }
    .frame(height: 100)
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 4)
  }
}
