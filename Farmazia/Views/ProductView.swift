import SwiftUI

struct ProductView: View {
  @StateObject var viewModel: ProductViewModel
  
  init(viewModel: @autoclosure @escaping () -> ProductViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {

        ProductImageView(imageURL: viewModel.product.image)
          .frame(height: 300)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(radius: 5)
        
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Text(viewModel.product.name)
              .font(.title)
              .fontWeight(.bold)
            Spacer()
            if viewModel.product.isOrganic {
              Text("Organic")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(20)
            }
          }

          HStack {
            Text("$\(String(format: "%.2f", viewModel.product.price))")
              .font(.title2)
              .fontWeight(.semibold)
              .foregroundColor(.green)
            Spacer()
            Text(viewModel.product.isOutOfStock ? "Out of Stock" : "In Stock")
              .font(.subheadline)
              .foregroundColor(viewModel.product.isOutOfStock ? .red : .green)
          }

          Text("Description")
            .font(.headline)
          Text(viewModel.product.description)
            .font(.body)
            .foregroundColor(.secondary)

          HStack {
            Text("Quantity:")
              .font(.headline)
            Spacer()
            CustomStepper(value: $viewModel.quantity, range: 1...viewModel.product.quantity)
          }
          .padding(.vertical, 8)

          Button(action: viewModel.addToCart) {
            Text("Add to Cart")
              .fontWeight(.semibold)
              .foregroundColor(.white)
              .padding()
              .frame(maxWidth: .infinity)
              .background(viewModel.product.isOutOfStock ? Color.gray : Color.green)
              .cornerRadius(12)
          }
          .disabled(viewModel.product.isOutOfStock)

          if let seller = viewModel.seller {
            VStack(alignment: .leading, spacing: 12) {
              Text("Seller Information")
                .font(.headline)
              
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  Text(seller.fullName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                  Text(seller.contactInformation.email)
                    .font(.caption)
                  Text(seller.contactInformation.phoneNumber)
                    .font(.caption)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                  Text("Rating")
                    .font(.caption)
                    .foregroundColor(.secondary)
                  Text(String(format: "%.1f", seller.rating))
                    .font(.headline)
                    .foregroundColor(.yellow)
                }
              }

              Text(seller.contactInformation.addressInformation.address)
                .font(.caption)
              Text("\(seller.contactInformation.addressInformation.city), \(seller.contactInformation.addressInformation.county)")
                .font(.caption)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
          }
        }
        .padding()
      }
    }
    .navigationTitle("Product Details")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await viewModel.fetchSellerInfo()
    }
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

