import SwiftUI
import Combine

struct CreateProductView: View {
  @StateObject private var viewModel: CreateProductViewModel
  @Environment(\.presentationMode) var presentationMode
  @Binding var shouldDismiss: Bool
  @State private var showingImagePicker = false

  init(
    sellerViewModel: SellerViewModel,
    storageManager: FirebaseStorageManagerProtocol,
    existingProduct: ProductModel? = nil,
    shouldDismiss: Binding<Bool>
  ) {
    self._viewModel = StateObject(
      wrappedValue: CreateProductViewModel(
        sellerViewModel: sellerViewModel,
        storageManager: storageManager,
        existingProduct: existingProduct
      )
    )
    self._shouldDismiss = shouldDismiss
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Product Image")) {
          if let image = viewModel.selectedImage {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
              .frame(height: 200)
          } else if let imageUrl = viewModel.existingProduct?.image {
            AsyncImage(url: URL(string: imageUrl)) { image in
              image.resizable().scaledToFit()
            } placeholder: {
              ProgressView()
            }
            .frame(height: 200)
          }
          Button(action: {
            showingImagePicker = true
          }) {
            Text(viewModel.selectedImage == nil ? "Select Image" : "Change Image")
          }
        }

        Section(header: Text("Product Details")) {
          TextField("Name", text: $viewModel.name)
          TextEditor(text: $viewModel.description)
            .frame(height: 100)
          TextField("Price", text: $viewModel.price)
            .keyboardType(.decimalPad)
          TextField("Quantity", text: $viewModel.quantity)
            .keyboardType(.numberPad)
        }

        Section(header: Text("Category")) {
          Picker("Category", selection: $viewModel.selectedCategory) {
            ForEach(ProductCategory.allCases, id: \.self) { category in
              Text(category.description).tag(category)
            }
          }
        }

        Section(header: Text("Unit")) {
          Picker("Unit", selection: $viewModel.selectedUnit) {
            ForEach(UnitType.allCases, id: \.self) { unit in
              Text(unit.rawValue).tag(unit)
            }
          }
        }

        Section {
          Toggle("Organic", isOn: $viewModel.isOrganic)
          Toggle("Out of Stock", isOn: $viewModel.isOutOfStock)
        }
      }
      .navigationTitle(viewModel.isEditMode ? "Edit Product" : "Add New Product")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          if viewModel.isEditMode {
            Button("Cancel") {
              presentationMode.wrappedValue.dismiss()
            }
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(viewModel.isEditMode ? "Save" : "Add") {
            saveProduct()
          }
        }
      }
      .alert(item: Binding<AlertItem?>(
        get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
        set: { _ in viewModel.errorMessage = nil }
      )) { alertItem in
        Alert(title: Text("Error"), message: Text(alertItem.message))
      }
      .sheet(isPresented: $showingImagePicker) {
        ImagePicker(image: $viewModel.selectedImage)
      }
    }
  }

  private func saveProduct() {
    Task {
      if await viewModel.saveProduct() {
        shouldDismiss = true
        presentationMode.wrappedValue.dismiss()
      }
    }
  }
}

struct AlertItem: Identifiable {
  let id = UUID()
  let message: String
}

struct ImagePicker: UIViewControllerRepresentable {
  @Binding var image: UIImage?

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      if let uiImage = info[.originalImage] as? UIImage {
        parent.image = uiImage
      }
      picker.dismiss(animated: true)
    }
  }
}
