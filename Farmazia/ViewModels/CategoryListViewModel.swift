import Foundation

@MainActor
class CategoryListViewModel: ObservableObject {
  @Published var searchText: String = ""
  @Published var debouncedSearchText: String = ""
  @Published var searchResults: [ProductModel] = []
  @Published var isSearching: Bool = false

  private let productService: ProductServiceProtocol

  init(productService: ProductServiceProtocol) {
    self.productService = productService
  }

  func debounceSearch(_ searchText: String) {
    isSearching = !searchText.isEmpty

    guard searchText.count >= 2 else {
      debouncedSearchText = ""
      searchResults = []
      return
    }

    Task {
      try? await Task.sleep(nanoseconds: 300_000_000) // 300ms delay
      if self.searchText == searchText {
        self.debouncedSearchText = searchText
        await self.performSearch()
      }
    }
  }

  func performSearch() async {
    do {
      searchResults = try await productService.searchProducts(by: debouncedSearchText)
    } catch {
      print("Error searching products: \(error)")
      searchResults = []
    }
  }
}
