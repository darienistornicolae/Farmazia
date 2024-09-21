import Foundation

@MainActor
class DependencyContainer {
  let appState: AppState
  lazy var productService: ProductServiceProtocol = ProductService(firestoreManager: firestoreManager)
  lazy var firestoreManager: FirestoreManagerProtocol = FirestoreManager()
  lazy var authenticationManager: AuthenticationManagerProtocol = AuthenticationManager()

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
    AuthenticationViewModel(authManager: authenticationManager)
  }
}
