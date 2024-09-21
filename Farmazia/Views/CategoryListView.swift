import SwiftUI

struct CategoryListView: View {
  @State private var path = NavigationPath()
  @State private var searchText = ""
  @State private var debouncedSearchText = ""
  @State private var searchResults: [ProductModel] = []
  @State private var isSearching = false

  var body: some View {
    NavigationStack(path: $path) {
      ScrollView {
        LazyVStack(spacing: 16) {
          if isSearching && !searchResults.isEmpty {
            searchResultsView
          } else if isSearching && searchResults.isEmpty {
            Text("No results found")
              .foregroundColor(.secondary)
              .padding()
          } else {
            categoryListView
          }
        }
        .padding()
      }
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search products")
      .onChange(of: searchText) { newValue in
        debounceSearch(newValue)
      }
      .navigationDestination(for: ProductListDestination.self) { destination in
        switch destination {
        case .allProducts:
          ProductListView(category: nil)
        case .category(let category):
          ProductListView(category: category)
        }
      }
      .navigationDestination(for: ProductModel.self) { product in
        ProductView(product: product)
      }
    }
  }
  
  private var searchResultsView: some View {
    ForEach(searchResults, id: \.id) { product in
      NavigationLink(value: product) {
        ProductCardView(product: product) {
          print("Added \(product.name) to cart")
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
  }

  private var categoryListView: some View {
    Group {
      NavigationLink(value: ProductListDestination.allProducts) {
        Text("All Products")
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(Color.secondary.opacity(0.1))
          .cornerRadius(8)
      }
      
      ForEach(ProductCategory.allCases, id: \.self) { category in
        NavigationLink(value: ProductListDestination.category(category)) {
          Text(category.rawValue.capitalized)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
      }
    }
  }
  
  private func debounceSearch(_ searchText: String) {
    isSearching = !searchText.isEmpty
    
    guard searchText.count >= 2 else {
      debouncedSearchText = ""
      searchResults = []
      return
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      if self.searchText == searchText {
        self.debouncedSearchText = searchText
        self.performSearch()
      }
    }
  }

  private func performSearch() {
    searchResults = MockData.products.filter { $0.name.lowercased().contains(debouncedSearchText.lowercased()) }
  }
}

enum ProductListDestination: Hashable {
  case allProducts
  case category(ProductCategory)
}

// For previews
struct CategoryListView_Previews: PreviewProvider {
  static var previews: some View {
    CategoryListView()
  }
}
