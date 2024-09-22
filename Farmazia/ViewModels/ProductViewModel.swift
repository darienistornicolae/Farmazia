import Foundation

@MainActor
class ProductViewModel: ObservableObject {
  @Published var product: ProductModel
  @Published var seller: SellerModel?
  @Published var quantity: Int = 1

  private let productService: ProductServiceProtocol

  init(product: ProductModel, productService: ProductServiceProtocol) {
    self.product = product
    self.productService = productService
  }

  func fetchSellerInfo() async {
    do {
      self.seller = try await productService.fetchSeller(withId: product.sellerId)
    } catch {
      print("Error fetching seller: \(error)")
    }
  }

  func addToCart() {
    print("Added \(quantity) \(product.name) to cart")
  }
}
