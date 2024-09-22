import Foundation
import FirebaseFirestore
import Firebase

class FirestoreManager: FirestoreManagerProtocol {
  private let dataBase = Firestore.firestore()

  func getDocument(from collection: String, documentId: String) async throws -> DocumentSnapshot {
    return try await dataBase.collection(collection).document(documentId).getDocument()
  }

  func getDocuments(from collection: String) async throws -> QuerySnapshot {
    return try await dataBase.collection(collection).getDocuments()
  }

  func getDocuments(from collection: String, whereField field: String, isEqualTo value: Any) async throws -> QuerySnapshot {
    return try await dataBase.collection(collection).whereField(field, isEqualTo: value).getDocuments()
  }

  func setData<T: Encodable>(_ object: T, in collection: String, documentId: String) async throws {
      let documentReference = dataBase.collection(collection).document(documentId)
      try documentReference.setData(from: object)
  }

  func addDocument<T: Encodable>(_ object: T, to collection: String) async throws -> DocumentReference {
      return try dataBase.collection(collection).addDocument(from: object)
  }

  func updateDocument<T: Encodable>(_ object: T, in collection: String, documentId: String) async throws {
      let documentReference = dataBase.collection(collection).document(documentId)
      try documentReference.setData(from: object, merge: true)
  }

  func deleteDocument(from collection: String, documentId: String) async throws {
    try await dataBase.collection(collection).document(documentId).delete()
  }

  func query(_ collection: String) -> Query {
    return dataBase.collection(collection)
  }

  func runQuery(_ query: Query) async throws -> QuerySnapshot {
    return try await query.getDocuments()
  }

  func addSnapshotListener(to collection: String, completion: @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration {
    return dataBase.collection(collection).addSnapshotListener(completion)
  }

  func addSnapshotListener(to collection: String, document documentId: String, completion: @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration {
    return dataBase.collection(collection).document(documentId).addSnapshotListener(completion)
  }
}
