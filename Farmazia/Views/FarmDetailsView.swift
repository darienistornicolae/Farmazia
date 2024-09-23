import SwiftUI

struct FarmDetailsView: View {
  @ObservedObject var viewModel: SellerViewModel
  @Environment(\.presentationMode) var presentationMode
  @State private var formState: FarmFormState

  init(viewModel: SellerViewModel) {
    self.viewModel = viewModel
    _formState = State(initialValue: FarmFormState(seller: viewModel.seller))
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Seller Information")) {
          TextField("Full Name", text: $formState.fullName)
          TextField("Email", text: $formState.email)
            .keyboardType(.emailAddress)
          TextField("Phone Number", text: $formState.phoneNumber)
            .keyboardType(.phonePad)
        }

        Section(header: Text("Farm Information")) {
          TextField("Farm Name", text: $formState.farmName)
          TextEditor(text: $formState.farmDescription)
            .frame(height: 100)
        }

        Section(header: Text("Address")) {
          TextField("City", text: $formState.city)
          TextField("County", text: $formState.county)
          TextField("Address", text: $formState.address)
          TextField("Postal Code", text: $formState.postalCode)
        }

        Section {
          Button("Save Changes") {
            saveChanges()
          }
        }
      }
      .navigationTitle("Edit Farm Details")
    }
  }

  private func saveChanges() {
    Task {
      await viewModel.createOrUpdateFarm(
        fullName: formState.fullName,
        email: formState.email,
        phoneNumber: formState.phoneNumber,
        farmName: formState.farmName,
        farmDescription: formState.farmDescription,
        addressInfo: AddressModel(
          city: formState.city,
          county: formState.county,
          address: formState.address,
          postalCode: formState.postalCode
        )
      )
      presentationMode.wrappedValue.dismiss()
    }
  }
}

struct FarmFormState {
  var fullName: String = ""
  var email: String = ""
  var phoneNumber: String = ""
  var farmName: String = ""
  var farmDescription: String = ""
  var city: String = ""
  var county: String = ""
  var address: String = ""
  var postalCode: String = ""

  init(seller: SellerModel?) {
    if let seller = seller {
      self.fullName = seller.fullName
      self.email = seller.contactInformation.email
      self.phoneNumber = seller.contactInformation.phoneNumber
      self.farmName = seller.farmName
      self.farmDescription = seller.farmDescription
      self.city = seller.contactInformation.addressInformation.city
      self.county = seller.contactInformation.addressInformation.county
      self.address = seller.contactInformation.addressInformation.address
      self.postalCode = seller.contactInformation.addressInformation.postalCode
    }
  }
}
