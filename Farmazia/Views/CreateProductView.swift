import SwiftUI

fileprivate enum Field: Hashable {
  case name, description, price, quantity
  static var allCases: [Field] {
    return [.name, .description, .price, .quantity]
  }
}

struct CreateProductView: View {
  @EnvironmentObject var dataManager: DataManager
  @Environment(\.dismiss) var dismiss
  @State private var showingImagePicker = false
  @FocusState private var focusedField: Field?

  @State private var name: String = ""
  @State private var description: String = ""
  @State private var price: String = ""
  @State private var quantity: String = ""
  @State private var selectedCategory: ProductCategory = .vegetables
  @State private var selectedUnit: UnitType = .kg
  @State private var isOrganic: Bool = false
  @State private var isOutOfStock: Bool = false
  @State private var selectedImage: UIImage?
  @State private var errorMessage: String?

  let existingProduct: ProductModel?
  var isEditMode: Bool = false

  init(existingProduct: ProductModel? = nil) {
    self.existingProduct = existingProduct
    _selectedImage = State(initialValue: nil)
  }

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Product Image")) {
          if let image = selectedImage {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
              .frame(height: 200)
          } else if let imageUrl = existingProduct?.image {
            ProductImageView(imageURL: imageUrl)
          }
          Button(action: {
            showingImagePicker = true
          }) {
            Text(selectedImage == nil ? "Select Image" : "Change Image")
          }
        }

        Section(header: Text("Product Details")) {
          TextField("Name", text: $name)
            .focused($focusedField, equals: .name)
            .submitLabel(.next)
            .onSubmit {
              focusedField = .description
            }
          TextEditor(text: $description)
            .focused($focusedField, equals: .description)
            .frame(height: 100)
            .onSubmit {
              focusedField = .price
            }
          TextField("Price", text: $price)
            .focused($focusedField, equals: .price)
            .keyboardType(.decimalPad)
            .submitLabel(.next)
            .onSubmit {
              focusedField = .quantity
            }
          TextField("Quantity", text: $quantity)
            .focused($focusedField, equals: .quantity)
            .keyboardType(.numberPad)
            .submitLabel(.done)
        }

        Section(header: Text("Category")) {
          Picker("Category", selection: $selectedCategory) {
            ForEach(ProductCategory.allCases, id: \.self) { category in
              Text(category.description).tag(category)
            }
          }
        }

        Section(header: Text("Unit")) {
          Picker("Unit", selection: $selectedUnit) {
            ForEach(UnitType.allCases, id: \.self) { unit in
              Text(unit.rawValue).tag(unit)
            }
          }
        }

        Section {
          Toggle("Organic", isOn: $isOrganic)
          Toggle("Out of Stock", isOn: $isOutOfStock)
        }
      }
      .keyboardToolbar(focusedField: $focusedField, fields: Field.allCases)
      .navigationTitle(isEditMode ? "Edit Product" : "Add New Product")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(isEditMode ? "Save" : "Add") {
            Task {
              await saveProduct()
            }
          }
        }
      }
      .sheet(isPresented: $showingImagePicker) {
        ImagePicker(image: $selectedImage)
      }
      .onAppear {
        setupInitialValues()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          focusedField = .name
        }
      }
    }
  }
}

// MARK: Private
private extension CreateProductView {
  private func setupInitialValues() {
    if let product = existingProduct {
      name = product.name
      description = product.description
      price = String(format: "%.2f", product.price)
      quantity = String(product.quantity)
      selectedCategory = product.productType
      selectedUnit = product.unit
      isOrganic = product.isOrganic
      isOutOfStock = product.isOutOfStock
    }
  }
  private func saveProduct() async {
    guard let priceValue = Double(price),
          let quantityValue = Int(quantity) else {
      errorMessage = "Invalid price or quantity"
      return
    }

    let product = ProductModel(
      id: existingProduct?.id,
      name: name,
      image: existingProduct?.image,
      description: description,
      sellerId: dataManager.currentSeller?.id ?? "",
      productType: selectedCategory,
      price: priceValue,
      quantity: quantityValue,
      unit: selectedUnit,
      isOrganic: isOrganic,
      isOutOfStock: isOutOfStock
    )
    
    do {
      if isEditMode {
        try await dataManager.updateProduct(product, image: selectedImage)
      } else {
        try await dataManager.addProduct(product, image: selectedImage)
      }
      dismiss()
    } catch {
      errorMessage = "Error saving product: \(error.localizedDescription)"
    }
  }
}
