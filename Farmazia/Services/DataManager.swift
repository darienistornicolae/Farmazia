import Foundation
import Combine
import UIKit

@MainActor
class DataManager: ObservableObject {
  @Published var currentSeller: SellerModel?
  @Published var products: [ProductModel] = []
  @Published var errorMessage: String?
  @Published var isAuthenticated: Bool = false

  private let sellerService: SellerServiceProtocol
  private let authManager: AuthenticationManagerProtocol
  private let productService: ProductServiceProtocol
  private var cancellables = Set<AnyCancellable>()
  private let storageManager: FirebaseStorageManagerProtocol

  init(
    sellerService: SellerServiceProtocol,
    authManager: AuthenticationManagerProtocol,
    productService: ProductServiceProtocol,
    storageManager: FirebaseStorageManagerProtocol
  ) {
    self.sellerService = sellerService
    self.authManager = authManager
    self.productService = productService
    self.storageManager = storageManager

    setupAuthStateListener()
  }

  private func setupAuthStateListener() {
    authManager.userPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] user in
        self?.isAuthenticated = user != nil
        if user != nil {
          self?.loadCurrentSeller()
        } else {
          self?.currentSeller = nil
          self?.products = []
        }
      }
      .store(in: &cancellables)
  }
  
  func loadCurrentSeller() {
    guard let userId = authManager.currentUser?.uid else {
      errorMessage = "No authenticated user found"
      return
    }
    
    Task {
      do {
        currentSeller = try await sellerService.getSeller(id: userId)
        await loadSellerProducts()
      } catch {
        errorMessage = "Failed to load seller: \(error.localizedDescription)"
      }
    }
  }
  
  func createOrUpdateFarm(
    fullName: String,
    email: String,
    phoneNumber: String,
    farmName: String,
    farmDescription: String,
    addressInfo: AddressModel
  ) {
    guard let userId = authManager.currentUser?.uid else {
      errorMessage = "No authenticated user found"
      return
    }

    Task {
      do {
        let newSeller = SellerModel(
          id: userId,
          fullName: fullName,
          contactInformation: ContactModel(
            email: email,
            phoneNumber: phoneNumber,
            addressInformation: addressInfo
          ),
          farmName: farmName,
          farmDescription: farmDescription,
          productIds: currentSeller?.productIds ?? [],
          rating: currentSeller?.rating ?? 0.0
        )
        
        if currentSeller != nil {
          try await sellerService.updateSeller(newSeller)
        } else {
          try await sellerService.createSeller(newSeller)
        }
        
        currentSeller = newSeller
      } catch {
        errorMessage = "Failed to create/update farm: \(error.localizedDescription)"
      }
    }
  }
  
  func loadSellerProducts() async {
    guard let sellerId = currentSeller?.id else {
      errorMessage = "Seller ID not found"
      return
    }

    do {
      products = try await productService.fetchProductsBySeller(sellerId: sellerId)
      
      if var updatedSeller = currentSeller {
        updatedSeller.productIds = products.compactMap { $0.id }
        currentSeller = updatedSeller
        try await sellerService.updateSeller(updatedSeller)
      }
    } catch {
      errorMessage = "Failed to load products: \(error.localizedDescription)"
    }
  }

  func uploadProductImage(_ image: UIImage) async throws -> String {
    let compressedImage = compressImage(image)
    let path = "product_images/\(UUID().uuidString).jpg"
    return try await storageManager.uploadImage(compressedImage, path: path)
  }

  private func compressImage(_ image: UIImage) -> UIImage {
    let maxSize: CGFloat = 500 // Maximum width or height
    let scale = min(maxSize / image.size.width, maxSize / image.size.height)
    
    if scale < 1 {
      let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
      let rect = CGRect(origin: .zero, size: newSize)
      
      UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
      image.draw(in: rect)
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage ?? image
    }
    
    return image
  }

  func addProduct(_ product: ProductModel, image: UIImage?) async throws {
    var newProduct = product
    
    if let image = image {
      let imageUrl = try await uploadProductImage(image)
      newProduct.image = imageUrl
    }
    
    let productId = try await productService.addProduct(newProduct)
    newProduct.id = productId
    products.append(newProduct)
    
    if var updatedSeller = currentSeller {
      updatedSeller.productIds.append(productId)
      try await sellerService.updateSeller(updatedSeller)
      currentSeller = updatedSeller
    }

    objectWillChange.send()
  }

  func updateProduct(_ product: ProductModel, image: UIImage?) async throws {
      var updatedProduct = product
      
      if let newImage = image {
          if let oldImagePath = product.image {
              try? await deleteProductImage(at: oldImagePath)
          }
          let imageUrl = try await uploadProductImage(newImage)
          updatedProduct.image = imageUrl
      } else {
          updatedProduct.image = product.image
      }
      try await productService.updateProduct(updatedProduct)
      if let index = products.firstIndex(where: { $0.id == updatedProduct.id }) {
          products[index] = updatedProduct
      }
      objectWillChange.send()
  }

  func deleteProduct(withId id: String) async throws {
      try await productService.deleteProduct(withId: id)
      products.removeAll { $0.id == id }
      
      if var updatedSeller = currentSeller {
        updatedSeller.productIds.removeAll { $0 == id }
        try await sellerService.updateSeller(updatedSeller)
        currentSeller = updatedSeller
      }
    }

  func deleteProductImage(at path: String) async throws {
    try await storageManager.deleteImage(at: path)
  }
  
  func moveProduct(from source: IndexSet, to destination: Int) {
    products.move(fromOffsets: source, toOffset: destination)
  }
}
