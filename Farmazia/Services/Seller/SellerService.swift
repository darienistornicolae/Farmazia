import Foundation
import FirebaseFirestore

class SellerService: SellerServiceProtocol {
  private let firestoreManager: FirestoreManagerProtocol
  private let collection = "sellers"

  init(firestoreManager: FirestoreManagerProtocol) {
    self.firestoreManager = firestoreManager
  }

  func createSeller(_ seller: SellerModel) async throws {
    let data = try JSONEncoder().encode(seller)
    let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
    if let id = seller.id {
      try await firestoreManager.setData(dict, in: collection, documentId: id)
    } else {
      _ = try await firestoreManager.addDocument(dict, to: collection)
    }
  }

  func getSeller(id: String) async throws -> SellerModel? {
    let document = try await firestoreManager.getDocument(from: collection, documentId: id)
    if let data = document.data(), document.exists {
      var seller = try JSONDecoder().decode(SellerModel.self, from: JSONSerialization.data(withJSONObject: data))
      seller.id = document.documentID
      return seller
    }
    return nil
  }

  func updateSeller(_ seller: SellerModel) async throws {
    guard let id = seller.id else { throw NSError(domain: "SellerService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Seller ID is missing"]) }
    let data = try JSONEncoder().encode(seller)
    let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
    try await firestoreManager.updateDocument(dict, in: collection, documentId: id)
  }

  func deleteSeller(id: String) async throws {
    try await firestoreManager.deleteDocument(from: collection, documentId: id)
  }
}
