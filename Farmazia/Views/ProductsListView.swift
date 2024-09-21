import SwiftUI

struct ProductListView: View {
  let category: ProductCategory?
  @State private var products: [ProductModel] = MockData.products
  @State private var sortOrder: SortOrder = .dateDescending
  
  var filteredAndSortedProducts: [ProductModel] {
    var result = products
    
    if let category = category {
      result = result.filter { $0.productType == category }
    }
    
    switch sortOrder {
    case .priceAscending:
      result.sort { $0.price < $1.price }
    case .priceDescending:
      result.sort { $0.price > $1.price }
    case .dateAscending:
      result.sort { $0.id < $1.id }
    case .dateDescending:
      result.sort { $0.id > $1.id }
    }
    
    return result
  }

  var body: some View {
    VStack {
      FilterBarView(sortOrder: $sortOrder)
        .padding(.horizontal)

      ScrollView {
        LazyVStack(spacing: 16) {
          ForEach(filteredAndSortedProducts, id: \.id) { product in
            NavigationLink(value: product) {
              ProductCardView(product: product) {
                print("Added \(product.name) to cart")
              }
            }
          }
        }
        .padding()
      }
    }
    .navigationTitle(category?.rawValue.capitalized ?? "All Products")
  }
}

struct FilterBarView: View {
  @Binding var sortOrder: SortOrder

  var body: some View {
    HStack {
      Spacer()

      Menu {
        Button("Price: Low to High") {
          sortOrder = .priceAscending
        }
        Button("Price: High to Low") {
          sortOrder = .priceDescending
        }
        Button("Newest") {
          sortOrder = .dateDescending
        }
        Button("Oldest") {
          sortOrder = .dateAscending
        }
      } label: {
        Image(systemName: "arrow.up.arrow.down")
          .foregroundColor(.primary)
      }
    }
    .padding([.leading, .trailing], 10)
  }
}
