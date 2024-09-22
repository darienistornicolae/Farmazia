import SwiftUI

struct ProductImageView: View {
  let imageURL: String?

  var body: some View {
    AsyncImage(url: URL(string: imageURL ?? "")) { phase in
      switch phase {
      case .empty:
        ProgressView()
          .frame(width: 300, height: 300)
      case .success(let image):
        image
          .resizable()
          .scaledToFill()
          .frame(height: 300)
          .clipped()
      case .failure:
        Image(systemName: "photo")
          .resizable()
          .scaledToFit()
          .foregroundColor(.gray)
          .frame(height: 300)
      @unknown default:
        EmptyView()
      }
    }
    .cornerRadius(10)
  }
}
