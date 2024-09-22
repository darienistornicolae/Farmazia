import Foundation

@MainActor
class ProductListViewModel: ObservableObject {
  @Published var products: [ProductModel] = []
  @Published var sortOrder: SortOrder = .dateDescending
  let category: ProductCategory?
  private let productService: ProductServiceProtocol

  init(category: ProductCategory? = nil, productService: ProductServiceProtocol) {
    self.category = category
    self.productService = productService
  }

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
      result.sort { $0.id ?? "" < $1.id ?? "" }
    case .dateDescending:
      result.sort { $0.id ?? "" > $1.id ?? "" }
    }

    return result
  }

  func fetchProducts() async {
    do {
      if let category = category {
        products = try await productService.fetchProductsByCategory(category)
      } else {
        products = try await productService.fetchAllProducts()
      }
    } catch {
      print("Error fetching products: \(error)")
    }
  }
}
