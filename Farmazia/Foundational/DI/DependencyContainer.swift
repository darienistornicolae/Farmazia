import Foundation

@MainActor
class DependencyContainer {
  let appState: AppState
  lazy var productService: ProductServiceProtocol = ProductService(firestoreManager: firestoreManager)
  lazy var firestoreManager: FirestoreManagerProtocol = FirestoreManager()
  lazy var authenticationManager: AuthenticationManagerProtocol = AuthenticationManager()
  lazy var sellerService: SellerServiceProtocol = SellerService(firestoreManager: firestoreManager)
  lazy var storageManager: FirebaseStorageManagerProtocol = FirebaseStorageManager()

  init() {
    self.appState = AppState()
  }

  func makeProductListViewModel(category: ProductCategory? = nil) -> ProductListViewModel {
    ProductListViewModel(category: category, productService: productService)
  }

  func makeProductViewModel(product: ProductModel) -> ProductViewModel {
    ProductViewModel(product: product, productService: productService)
  }

  func makeCategoryListViewModel() -> CategoryListViewModel {
    CategoryListViewModel(productService: productService)
  }

  func makeAuthenticationViewModel() -> AuthenticationViewModel {
    AuthenticationViewModel(
      authManager: authenticationManager,
      sellerService: sellerService,
      productService: productService
    )
  }

  func makeCreateProductViewModel(sellerViewModel: SellerViewModel) -> CreateProductViewModel {
    CreateProductViewModel(sellerViewModel: sellerViewModel, storageManager: storageManager)
  }

  func makeSellerViewModel() -> SellerViewModel {
    SellerViewModel(sellerService: sellerService, authManager: authenticationManager, productService: productService)
  }
}
