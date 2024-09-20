import SwiftUI

struct FilterBarView: View {
  @Binding var selectedCategory: ProductCategory?
  @Binding var sortOrder: SortOrder
  
  var body: some View {
    HStack {
      Menu {
        Button("All") {
          selectedCategory = nil
        }

        ForEach(ProductCategory.allCases, id: \.self) { category in
          Button(category.rawValue.capitalized) {
            selectedCategory = category
          }
        }
      } label: {
        Image(systemName: "list.bullet")
          .foregroundColor(.primary)
      }

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

struct SortPickerView: View {
  @Binding var sortOrder: SortOrder

  var body: some View {
    List {
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
    }
  }
}

struct ProductListView: View {
  @State private var products: [ProductModel]
  @State private var selectedCategory: ProductCategory?
  @State private var sortOrder: SortOrder = .dateDescending
  
  init(products: [ProductModel] = []) {
    _products = State(initialValue: products)
  }
  
  var filteredAndSortedProducts: [ProductModel] {
    var result = products
    
    if let category = selectedCategory {
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
    NavigationView {
      VStack {
        FilterBarView(selectedCategory: $selectedCategory, sortOrder: $sortOrder)
          .padding(.horizontal)

        ScrollView {
          LazyVStack(spacing: 16) {
            ForEach(filteredAndSortedProducts, id: \.id) { product in
              NavigationLink(destination: ProductView(product: product)) {
                ProductCardView(product: product) {
                  print("Added \(product.name) to cart")
                }
              }
            }
          }
          .padding()
        }
      }
      .navigationTitle("Organic Farm Shop")
    }
  }
}
