import SwiftUI

struct DecoratedTextView: View {
    
    let placeholderText: String
    @Binding var textValue: String
    @Binding var errorMessage: String?
    var hintLabel: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(placeholderText, text: $textValue)
                .disableAutocorrection(true)
            VStack {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                } else if let hintLabel = hintLabel {
                    Text(hintLabel)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }.padding([.leading], 8)
        }
    }
}

struct ValidatingTextView_Previews: PreviewProvider {
    static var previews: some View {
        DecoratedTextView(placeholderText: "Enter value",
                          textValue: .constant("Some Text"),
                           errorMessage: .constant(nil),
                           hintLabel: "Hint")
            .previewDisplayName("Default State")
        DecoratedTextView(placeholderText: "Enter value",
                          textValue: .constant("Some Text"),
                           errorMessage: .constant("Error Message"),
                           hintLabel: "Hint")
            .previewDisplayName("Error State")
    }
}
