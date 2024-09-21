import Foundation

protocol SellerServiceProtocol {
  func createSeller(_ seller: SellerModel) async throws
  func getSeller(id: String) async throws -> SellerModel?
  func updateSeller(_ seller: SellerModel) async throws
  func deleteSeller(id: String) async throws
}
