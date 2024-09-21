import SwiftUI

struct CategoryListView: View {
    @StateObject var viewModel: CategoryListViewModel
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if viewModel.isSearching && !viewModel.searchResults.isEmpty {
                        searchResultsView
                    } else if viewModel.isSearching && viewModel.searchResults.isEmpty {
                        Text("No results found")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        categoryListView
                    }
                }
                .padding()
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search products")
            .onChange(of: viewModel.searchText) { newValue in
                viewModel.debounceSearch(newValue)
            }
            .navigationDestination(for: ProductListDestination.self) { destination in
                switch destination {
                case .allProducts:
                    ProductListView(viewModel: DependencyContainer().makeProductListViewModel())
                case .category(let category):
                    ProductListView(viewModel: DependencyContainer().makeProductListViewModel(category: category))
                }
            }
            .navigationDestination(for: ProductModel.self) { product in
                ProductView(viewModel: DependencyContainer().makeProductViewModel(product: product))
            }
        }
    }
    
    private var searchResultsView: some View {
        ForEach(viewModel.searchResults, id: \.id) { product in
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
}


enum ProductListDestination: Hashable {
  case allProducts
  case category(ProductCategory)
}
