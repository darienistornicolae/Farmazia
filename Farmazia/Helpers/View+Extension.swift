import SwiftUI

struct KeyboardToolbarModifier<Field: Hashable>: ViewModifier {
  @FocusState.Binding var focusedField: Field?
  let fields: [Field]
  
  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Button(action: previousField) {
            Image(systemName: "chevron.up")
          }
          .disabled(focusedField == fields.first)
          
          Button(action: nextField) {
            Image(systemName: "chevron.down")
          }
          .disabled(focusedField == fields.last)
          
          Spacer()
          
          Button("Done") {
            hideKeyboard()
          }
        }
      }
  }
  
  private func previousField() {
    if let currentField = focusedField, let currentIndex = fields.firstIndex(of: currentField) {
      let previousIndex = max(0, currentIndex - 1)
      focusedField = fields[previousIndex]
    }
  }
  
  private func nextField() {
    if let currentField = focusedField, let currentIndex = fields.firstIndex(of: currentField) {
      let nextIndex = min(fields.count - 1, currentIndex + 1)
      focusedField = fields[nextIndex]
    }
  }
  
  private func hideKeyboard() {
    focusedField = nil
  }
}

extension View {
  func keyboardToolbar<Field: Hashable>(focusedField: FocusState<Field?>.Binding, fields: [Field]) -> some View {
    self.modifier(KeyboardToolbarModifier(focusedField: focusedField, fields: fields))
  }
}
