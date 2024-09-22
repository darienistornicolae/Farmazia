import SwiftUI

struct ProductView: View {
  @StateObject var viewModel: ProductViewModel

  init(viewModel: @autoclosure @escaping () -> ProductViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        ProductImageView(imageURL: viewModel.product.image)
        Text(viewModel.product.name)
          .font(.title)
          .fontWeight(.bold)

        Text(viewModel.product.description)
          .font(.body)
        
        HStack {
          Text("Price: $\(String(format: "%.2f", viewModel.product.price))")
            .font(.headline)
          
          Spacer()
          
          Text("Available: \(viewModel.product.quantity) \(viewModel.product.unit.rawValue)")
            .font(.subheadline)
        }
        
        HStack {
          if viewModel.product.isOrganic {
            Text("Organic")
              .font(.caption)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.green.opacity(0.2))
              .cornerRadius(4)
          }
          
          Spacer()
          
          CustomStepper(value: $viewModel.quantity, range: 1...viewModel.product.quantity)
        }
        if let seller = viewModel.seller {
          VStack(alignment: .leading, spacing: 8) {
            Text("Seller Information")
              .font(.headline)
            
            Text(seller.fullName)
              .font(.subheadline)
            
            Text(seller.contactInformation.email)
              .font(.caption)
            
            Text(seller.contactInformation.phoneNumber)
              .font(.caption)
            
            Text(seller.contactInformation.addressInformation.address)
              .font(.caption)
            
            Text("\(seller.contactInformation.addressInformation.city), \(seller.contactInformation.addressInformation.county)")
              .font(.caption)
            
            Text("Seller Rating: \(String(format: "%.1f", seller.rating))")
              .font(.caption)
              .fontWeight(.bold)
          }
        }
        Button(action: viewModel.addToCart) {
                            Text("Add to Cart")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(viewModel.product.isOutOfStock ? Color.gray : Color.green)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.product.isOutOfStock)
                    }
                    .padding()
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

