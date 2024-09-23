import SwiftUI

struct CreateFarmView: View {
  @ObservedObject var viewModel: SellerViewModel
  @Environment(\.dismiss) var dismiss

  @State private var fullName: String = ""
  @State private var email: String = ""
  @State private var phoneNumber: String = ""
  @State private var farmName: String = ""
  @State private var farmDescription: String = ""
  @State private var city: String = ""
  @State private var county: String = ""
  @State private var address: String = ""
  @State private var postalCode: String = ""

  var body: some View {
    Form {
      Section(header: Text("Seller Information")) {
        TextField("Full Name", text: $fullName)
        TextField("Email", text: $email)
          .keyboardType(.emailAddress)
        TextField("Phone Number", text: $phoneNumber)
          .keyboardType(.phonePad)
      }

      Section(header: Text("Farm Information")) {
        TextField("Farm Name", text: $farmName)
        TextEditor(text: $farmDescription)
          .frame(height: 100)
      }

      Section(header: Text("Address")) {
        TextField("City", text: $city)
        TextField("County", text: $county)
        TextField("Address", text: $address)
        TextField("Postal Code", text: $postalCode)
      }

      Section {
        Button("Save Farm") {
          Task {
            await saveFarm()
          }
        }
      }
    }
    .navigationTitle("Create Your Farm")
    .onChange(of: viewModel.farmCreated) { created in
      if created {
        dismiss()
      }
    }
  }

  func saveFarm() async {
    let addressInfo = AddressModel(
      city: city,
      county: county,
      address: address,
      postalCode: postalCode
    )

    await viewModel.createOrUpdateFarm(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      farmName: farmName,
      farmDescription: farmDescription,
      addressInfo: addressInfo
    )
  }
}
