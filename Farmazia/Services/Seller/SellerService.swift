import Foundation
import FirebaseFirestore

class SellerService: SellerServiceProtocol {
  private let firestoreManager: FirestoreManagerProtocol
  private let sellerCollection = "sellers"

  init(firestoreManager: FirestoreManagerProtocol) {
    self.firestoreManager = firestoreManager
  }

  func createSeller(_ seller: SellerModel) async throws {
    guard let id = seller.id else {
      throw NSError(domain: "SellerService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Seller ID is missing"])
    }
    try await firestoreManager.setData(seller, in: sellerCollection, documentId: id)
  }

  func getSeller(id: String) async throws -> SellerModel? {
    let document = try await firestoreManager.getDocument(from: sellerCollection, documentId: id)
    return try? document.data(as: SellerModel.self)
  }

  func updateSeller(_ seller: SellerModel) async throws {
    guard let id = seller.id else {
      throw NSError(domain: "SellerService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Seller ID is missing"])
    }
    try await firestoreManager.updateDocument(seller, in: sellerCollection, documentId: id)
  }

  func deleteSeller(id: String) async throws {
    try await firestoreManager.deleteDocument(from: sellerCollection, documentId: id)
  }
}
