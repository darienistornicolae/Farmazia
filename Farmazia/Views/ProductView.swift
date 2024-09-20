import SwiftUI

struct ProductView: View {
  let product: ProductModel
  @State private var quantity: Int = 1

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          AsyncImage(url: URL(string: product.image ?? "")) { image in
            image.resizable().aspectRatio(contentMode: .fit)
          } placeholder: {
            Color.gray
          }
          .frame(height: 300)

          Text(product.name)
            .font(.title)
            .fontWeight(.bold)

          Text(product.description)
            .font(.body)

          HStack {
            Text("Price: $\(String(format: "%.2f", product.price))")
              .font(.headline)

            Spacer()

            Text("Available: \(product.quantity) \(product.unit.rawValue)")
              .font(.subheadline)
          }

          HStack {
            if product.isOrganic {
              Text("Organic")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(4)
            }
            Spacer()
            CustomStepper(value: $quantity, range: 1...product.quantity)
          }
          Divider()

          VStack(alignment: .leading, spacing: 8) {
            Text("Seller Information")
              .font(.headline)

            Text(product.seller.fullName)
              .font(.subheadline)

            Text(product.seller.contactInformation.email)
              .font(.caption)

            Text(product.seller.contactInformation.phoneNumber)
              .font(.caption)

            Text(product.seller.contactInformation.addressInformation.address)
              .font(.caption)

            Text("\(product.seller.contactInformation.addressInformation.city), \(product.seller.contactInformation.addressInformation.county)")
              .font(.caption)

            Text("Seller Rating: \(String(format: "%.1f", product.seller.rating))")
              .font(.caption)
              .fontWeight(.bold)
          }
        }
        .padding()
      }

      Button(action: {
        print("Added \(quantity) \(product.name) to cart")
      }) {
        Text("Add to Cart")
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .padding()
          .frame(maxWidth: .infinity)
          .background(product.isOutOfStock ? Color.gray : Color.green)
          .cornerRadius(8)
      }
      .disabled(product.isOutOfStock)
      .padding()
      .background(Color.white)
      .shadow(radius: 2)
    }
    .navigationTitle("Product Details")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct CustomStepper: View {
  @Binding var value: Int
  let range: ClosedRange<Int>

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)

      HStack(spacing: 0) {
        Button(action: decrement) {
          Text("-")
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .foregroundStyle(.green)

        Divider()

        Text("\(value)")
          .font(.headline)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .frame(minWidth: 40)

        Divider()

        Button(action: increment) {
          Text("+")
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .foregroundStyle(value < range.upperBound ? .green : .gray)
      }
    }
    .fixedSize(horizontal: true, vertical: true)
  }

  private func increment() {
    if value < range.upperBound {
      value += 1
    }
  }

  private func decrement() {
    if value > range.lowerBound {
      value -= 1
    }
  }
}

#Preview {
  NavigationView {
    ProductView(product: MockData.products.first!)
  }
}
