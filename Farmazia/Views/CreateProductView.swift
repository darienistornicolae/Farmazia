import SwiftUI
import Combine

struct CreateProductView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var showingImagePicker = false
    
    // Product properties
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
    
    var isEditMode: Bool { existingProduct != nil }
    
    init(existingProduct: ProductModel? = nil) {
        self.existingProduct = existingProduct
        
        if let product = existingProduct {
            _name = State(initialValue: product.name)
            _description = State(initialValue: product.description)
            _price = State(initialValue: String(format: "%.2f", product.price))
            _quantity = State(initialValue: String(product.quantity))
            _selectedCategory = State(initialValue: product.productType)
            _selectedUnit = State(initialValue: product.unit)
            _isOrganic = State(initialValue: product.isOrganic)
            _isOutOfStock = State(initialValue: product.isOutOfStock)
        }
    }

    var body: some View {
        NavigationView {
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
                    TextEditor(text: $description)
                        .frame(height: 100)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
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
            .navigationTitle(isEditMode ? "Edit Product" : "Add New Product")
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
            .alert("Error", isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Text(errorMessage ?? "An unknown error occurred")
            }
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
            await dataManager.loadSellerProducts()  // Reload products after update
            dismiss()
        } catch {
            errorMessage = "Error saving product: \(error.localizedDescription)"
        }
    }
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
