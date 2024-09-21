import SwiftUI

struct ProductListView: View {
  @StateObject private var viewModel: ProductListViewModel

  init(viewModel: @autoclosure @escaping () -> ProductListViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    VStack {
      FilterBarView(sortOrder: $viewModel.sortOrder)
        .padding(.horizontal)

      ScrollView {
        LazyVStack(spacing: 16) {
          ForEach(viewModel.filteredAndSortedProducts, id: \.id) { product in
            NavigationLink(value: product) {
              ProductCardView(product: product) {
                print("Added \(product.name) to cart")
              }
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
        .padding()
      }
    }
    .navigationTitle(viewModel.category?.description ?? "All Products")
    .task {
      await viewModel.fetchProducts()
    }
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
