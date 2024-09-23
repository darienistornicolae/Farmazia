import SwiftUI

struct ProductView: View {
  @StateObject var viewModel: ProductViewModel

  init(viewModel: @autoclosure @escaping () -> ProductViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          ProductImageView(imageURL: viewModel.product.image)
            .frame(height: 300)
            .frame(width: geometry.size.width)

          VStack(alignment: .leading, spacing: 16) {
            productHeaderSection
            productDescriptionSection
            quantitySection
            addToCartButton
            sellerSection
          }
          .padding(.horizontal)
          .frame(width: geometry.size.width)
        }
      }
      .frame(width: geometry.size.width)
    }
    .navigationTitle("Product Details")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await viewModel.fetchSellerInfo()
    }
  }
}

// MARK: Private
private extension ProductView {
  var productHeaderSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(viewModel.product.name)
        .font(.title2)
        .fontWeight(.bold)
        .fixedSize(horizontal: false, vertical: true)

      HStack {
        Text("$\(String(format: "%.2f", viewModel.product.price))")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(.green)

        Spacer()

        stockStatusView
        if viewModel.product.isOrganic {
          organicBadge
        }
      }
    }
  }

  var stockStatusView: some View {
    Text(viewModel.product.isOutOfStock ? "Out of Stock" : "In Stock")
      .font(.subheadline)
      .fontWeight(.medium)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(viewModel.product.isOutOfStock ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
      .foregroundColor(viewModel.product.isOutOfStock ? .red : .green)
      .cornerRadius(4)
  }

  var organicBadge: some View {
    Text("Organic")
      .font(.caption)
      .fontWeight(.medium)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(Color.green.opacity(0.2))
      .foregroundColor(.green)
      .cornerRadius(4)
  }

  var productDescriptionSection: some View {
    Text(viewModel.product.description)
      .font(.body)
      .foregroundColor(.secondary)
      .fixedSize(horizontal: false, vertical: true)
  }

  var quantitySection: some View {
    HStack {
      Text("Quantity:")
        .font(.headline)
      Spacer()
      CustomStepper(value: $viewModel.quantity, range: 1...viewModel.product.quantity)
    }
  }

  var addToCartButton: some View {
    Button(action: viewModel.addToCart) {
      Text("Add to Cart")
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.product.isOutOfStock ? Color.gray : Color.green)
        .cornerRadius(10)
    }
    .disabled(viewModel.product.isOutOfStock)
  }

  var sellerSection: some View {
    Group {
      if let seller = viewModel.seller {
        SellerCardView(seller: seller)
      }
    }
  }
}
