import SwiftUI

struct FarmDetailsView: View {
  @ObservedObject var viewModel: SellerViewModel
  @Environment(\.presentationMode) var presentationMode
  @State private var farmName: String = ""
  @State private var farmDescription: String = ""
  @State private var city: String = ""
  @State private var county: String = ""
  @State private var address: String = ""
  @State private var postalCode: String = ""

  var body: some View {
    NavigationView {
      Form {
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
          Button("Save Changes") {
            saveChanges()
          }
        }
      }
      .navigationTitle("Edit Farm Details")
      .onAppear(perform: loadFarmDetails)
    }
  }

  private func loadFarmDetails() {
    if let seller = viewModel.seller {
      farmName = seller.farmName
      farmDescription = seller.farmDescription
      city = seller.contactInformation.addressInformation.city
      county = seller.contactInformation.addressInformation.county
      address = seller.contactInformation.addressInformation.address
      postalCode = seller.contactInformation.addressInformation.postalCode
    }
  }

  private func saveChanges() {
    let updatedAddressInfo = AddressModel(city: city, county: county, address: address, postalCode: postalCode)
    Task {
      await viewModel.createOrUpdateFarm(farmName: farmName, farmDescription: farmDescription, addressInfo: updatedAddressInfo)
      presentationMode.wrappedValue.dismiss()
    }
  }
}
