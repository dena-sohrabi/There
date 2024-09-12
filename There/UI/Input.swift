import SwiftUI

struct AdaptiveColors {
    static let textFieldBackground = Color(.textBackgroundColor)
    static let textFieldBorder = Color.secondary
    static let textColor = Color.primary
}

struct Input: View {
    @Binding var text: String
    var placeholder: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(.horizontal, 6)
            .frame(width: 200, height: 32)
            .background(AdaptiveColors.textFieldBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? AdaptiveColors.textFieldBorder.opacity(0.8) : AdaptiveColors.textFieldBorder.opacity(0.5), lineWidth: 1)
            )
            .focused($isFocused)
            .foregroundColor(AdaptiveColors.textColor)
    }
}

struct CompactInput: View {
    @Binding var text: String
    var placeholder: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(.horizontal, 6)
            .frame(height: 32)
            .background(AdaptiveColors.textFieldBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? AdaptiveColors.textFieldBorder.opacity(0.8) : AdaptiveColors.textFieldBorder.opacity(0.5), lineWidth: 1)
            )
            .padding(.bottom)
            .focused($isFocused)
            .scaledToFill()
            .foregroundColor(AdaptiveColors.textColor)
    }
}

struct AutocompleteInput: View {
    @Binding var text: String
    let placeholder: String
    let suggestions: [String]
    let onCommit: () -> Void

    @State private var isEditing = false
    @State private var showSuggestions = false

    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $text, onEditingChanged: { editing in
                isEditing = editing
                showSuggestions = editing && !suggestions.isEmpty
            }, onCommit: {
                showSuggestions = false
                onCommit()
            })
            .textFieldStyle(CustomTextFieldStyle(isFocused: isEditing))
            .onChange(of: text) { _ in
                showSuggestions = isEditing && !suggestions.isEmpty
            }

            if showSuggestions {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                            Text(suggestion)
                                .padding(.vertical, 2)
                                .onTapGesture {
                                    text = suggestion
                                    showSuggestions = false
                                    onCommit()
                                }
                        }
                    }
                }
                .frame(maxHeight: 150)
                .background(AdaptiveColors.textFieldBackground)
                .cornerRadius(5)
                .shadow(color: Color.primary.opacity(0.2), radius: 5)
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    var isFocused: Bool

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 6)
            .frame(height: 32)
            .background(AdaptiveColors.textFieldBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? AdaptiveColors.textFieldBorder.opacity(0.8) : AdaptiveColors.textFieldBorder.opacity(0.5), lineWidth: 1)
            )
            .foregroundColor(AdaptiveColors.textColor)
    }
}
