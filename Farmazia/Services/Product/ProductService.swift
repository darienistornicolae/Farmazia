import Foundation
import FirebaseFirestore

class ProductService: ProductServiceProtocol {
  private let firestoreManager: FirestoreManagerProtocol
  private let collectionName = "products"
  private let sellerCollection = "sellers"
  init(firestoreManager: FirestoreManagerProtocol) {
    self.firestoreManager = firestoreManager
  }

  func fetchSeller(withId id: String) async throws -> SellerModel {
    let document = try await firestoreManager.getDocument(from: sellerCollection, documentId: id)
    return try document.data(as: SellerModel.self)
  }

  func fetchAllProducts() async throws -> [ProductModel] {
    let snapshot = try await firestoreManager.getDocuments(from: collectionName)
    return try snapshot.documents.compactMap { try $0.data(as: ProductModel.self) }
  }

  func fetchProduct(withId id: String) async throws -> ProductModel? {
    let document = try await firestoreManager.getDocument(from: collectionName, documentId: id)
    return try? document.data(as: ProductModel.self)
  }

  func fetchProductsByCategory(_ category: ProductCategory) async throws -> [ProductModel] {
    let snapshot = try await firestoreManager.getDocuments(from: collectionName, whereField: "productType", isEqualTo: category.rawValue)
    return try snapshot.documents.compactMap { try $0.data(as: ProductModel.self) }
  }

  func fetchProductsBySeller(sellerId: String) async throws -> [ProductModel] {
    let snapshot = try await firestoreManager.getDocuments(from: collectionName, whereField: "seller.id", isEqualTo: sellerId)
    return try snapshot.documents.compactMap { try $0.data(as: ProductModel.self) }
  }

  func addProduct(_ product: ProductModel) async throws -> String {
    let data = try product.asDictionary()
    let documentRef = try await firestoreManager.addDocument(data, to: collectionName)
    return documentRef.documentID
  }

  func updateProduct(_ product: ProductModel) async throws {
    let data = try product.asDictionary()
    try await firestoreManager.updateDocument(data, in: collectionName, documentId: product.id ?? "")
  }

  func deleteProduct(withId id: String) async throws {
    try await firestoreManager.deleteDocument(from: collectionName, documentId: id)
  }

  func searchProducts(by searchTerm: String) async throws -> [ProductModel] {
    let snapshot = try await firestoreManager.getDocuments(from: collectionName)
    let allProducts = try snapshot.documents.compactMap { try $0.data(as: ProductModel.self) }
    return allProducts.filter { $0.name.lowercased().contains(searchTerm.lowercased()) }
  }

  func fetchFeaturedProducts(limit: Int) async throws -> [ProductModel] {
    let query = firestoreManager.query(collectionName).whereField("isFeatured", isEqualTo: true).limit(to: limit)
    let snapshot = try await firestoreManager.runQuery(query)
    return try snapshot.documents.compactMap { try $0.data(as: ProductModel.self) }
  }

  func addProductListener(completion: @escaping ([ProductModel]) -> Void) -> ListenerRegistration {
    return firestoreManager.addSnapshotListener(to: collectionName) { querySnapshot, error in
      guard let documents = querySnapshot?.documents else {
        print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
        return
      }
      let products = documents.compactMap { try? $0.data(as: ProductModel.self) }
      completion(products)
    }
  }
}

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"])
    }
    return dictionary
  }
}
