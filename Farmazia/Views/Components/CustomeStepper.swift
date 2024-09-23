import SwiftUI

struct CustomStepper: View {
  @Binding var value: Int
  let range: ClosedRange<Int>

  var body: some View {
    HStack {
      Button(action: decrement) {
        Image(systemName: "minus")
      }
      .disabled(value <= range.lowerBound)

      Text("\(value)")
        .frame(minWidth: 40)

      Button(action: increment) {
        Image(systemName: "plus")
      }
      .disabled(value >= range.upperBound)
    }
    .padding(6)
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(8)
  }

  private func increment() {
    if value < range.upperBound {
      value += 1
    }
  }

  private func decrement() {
    if value > range.lowerBound {
      value -= 1
    }
  }
}
