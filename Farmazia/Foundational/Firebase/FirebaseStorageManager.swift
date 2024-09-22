import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageManager: FirebaseStorageManagerProtocol {
  private let storage = Storage.storage()

  func uploadImage(_ image: UIImage, path: String) async throws -> String {
    guard let imageData = image.jpegData(compressionQuality: 0.7) else {
      throw NSError(domain: "FirebaseStorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
    }

    let storageRef = storage.reference().child(path)
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"

    let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
    let downloadURL = try await storageRef.downloadURL()
    return downloadURL.absoluteString
  }

  func downloadImage(from urlString: String) async throws -> UIImage {
    guard let url = URL(string: urlString) else {
      throw NSError(domain: "FirebaseStorageManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    guard let image = UIImage(data: data) else {
      throw NSError(domain: "FirebaseStorageManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from data"])
    }
    return image
  }

  func deleteImage(at path: String) async throws {
    let storageRef = storage.reference().child(path)
    try await storageRef.delete()
  }
}
