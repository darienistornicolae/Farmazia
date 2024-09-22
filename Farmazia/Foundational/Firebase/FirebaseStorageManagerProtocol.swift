import Foundation
import UIKit

protocol FirebaseStorageManagerProtocol {
  func uploadImage(_ image: UIImage, path: String) async throws -> String
  func downloadImage(from urlString: String) async throws -> UIImage
  func deleteImage(at path: String) async throws
}

