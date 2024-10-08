import Foundation
import FirebaseFirestore

protocol FirestoreManagerProtocol {

  // MARK: - CRUD Operations
  func getDocument(from collection: String, documentId: String) async throws -> DocumentSnapshot
  func getDocuments(from collection: String) async throws -> QuerySnapshot
  func getDocuments(from collection: String, whereField field: String, isEqualTo value: Any) async throws -> QuerySnapshot

  func setData<T: Encodable>(_ object: T, in collection: String, documentId: String) async throws
  func addDocument<T: Encodable>(_ object: T, to collection: String) async throws -> DocumentReference
  func updateDocument<T: Encodable>(_ object: T, in collection: String, documentId: String) async throws
  func deleteDocument(from collection: String, documentId: String) async throws

  // MARK: - Querying
  func query(_ collection: String) -> Query
  func runQuery(_ query: Query) async throws -> QuerySnapshot

  // MARK: - Listening
  func addSnapshotListener(to collection: String, completion: @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration
  func addSnapshotListener(to collection: String, document documentId: String, completion: @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration
}
