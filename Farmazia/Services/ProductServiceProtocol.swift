import Foundation
import FirebaseFirestore

protocol ProductServiceProtocol {
  func fetchAllProducts() async throws -> [ProductModel]
  func fetchProduct(withId id: String) async throws -> ProductModel?
  func fetchProductsByCategory(_ category: ProductCategory) async throws -> [ProductModel]
  func fetchProductsBySeller(sellerId: String) async throws -> [ProductModel]
  func addProduct(_ product: ProductModel) async throws -> String
  func updateProduct(_ product: ProductModel) async throws
  func deleteProduct(withId id: String) async throws
  func searchProducts(by searchTerm: String) async throws -> [ProductModel]
  func fetchFeaturedProducts(limit: Int) async throws -> [ProductModel]
  func addProductListener(completion: @escaping ([ProductModel]) -> Void) -> ListenerRegistration
}
