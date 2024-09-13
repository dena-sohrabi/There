import SwiftUI

// PrimaryButton
struct PrimaryButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let lightBlue = Color(red: 0.24, green: 0.67, blue: 0.91) // #3DAAE8
    let darkBlue = Color(red: 0.22, green: 0.60, blue: 0.82) // #3799D1

    @State private var hovered: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .fontWeight(.medium)
            .frame(width: 200, height: 32)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(hovered ? lightBlue.opacity(0.85) : lightBlue)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(hovered ? darkBlue.opacity(0.6) : darkBlue, lineWidth: 3)
                }
            )
            .cornerRadius(8)
            .shadow(color: .primary.opacity(0.08), radius: 1, x: 0, y: configuration.isPressed ? 0 : (hovered ? 3 : 1))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                withAnimation {
                    self.hovered = hovering
                }
            }
    }
}

// SecondaryButton
struct SecondaryButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.primary)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var scheme

    var white: Color {
        if scheme == .dark {
            return Color(.gray).opacity(0.2)
        } else {
            return Color(red: 1.0, green: 1.0, blue: 1.0)
        }
    }

    var lightGray: Color {
        if scheme == .dark {
            return Color(NSColor.systemGray).opacity(0.2)
        } else {
            return Color(red: 0.86, green: 0.86, blue: 0.86) // #DCDCDC
        }
    }

    @State private var hovered: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .padding(.horizontal, 6)
            .foregroundColor(.primary.opacity(0.8))
            .fontWeight(.medium)
            .frame(width: 200, height: 32)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(hovered ? white.opacity(0.85) : white)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(hovered ? lightGray.opacity(0.6) : lightGray, lineWidth: 3)
                }
            )
            .cornerRadius(8)
            .shadow(color: .primary.opacity(0.08), radius: 1, x: 0, y: configuration.isPressed ? 0 : (hovered ? 3 : 1))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                withAnimation {
                    self.hovered = hovering
                }
            }
    }
}

// CompactButton
struct CompactButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(CompactButtonStyle())
    }
}

struct CompactButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var scheme

    var lightGray: Color {
        if scheme == .dark {
            return Color(NSColor.systemGray).opacity(0.2)
        } else {
            return Color(red: 0.86, green: 0.86, blue: 0.86) // #DCDCDC
        }
    }

    @State private var hovered: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .foregroundColor(.primary)
            .fontWeight(.medium)
            .frame(height: 28)
            .background(hovered ? (scheme == .dark ? Color(.gray).opacity(0.2) : .white) : (scheme == .dark ? Color(.gray).opacity(0.3) : .white.opacity(0.8)))
            .cornerRadius(8)
            .shadow(color: .primary.opacity(0.04), radius: 1, x: 0, y: configuration.isPressed ? 0 : (hovered ? 2 : 1))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                withAnimation {
                    self.hovered = hovering
                }
            }
    }
}

// CompactPrimaryButton
struct CompactPrimaryButton: View {
    var title: String
    var action: () -> Void
    var width: CGFloat = 232

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(CompactPrimaryButtonStyle(width: width))
    }
}

struct CompactPrimaryButtonStyle: ButtonStyle {
    let lightBlue = Color(red: 0.24, green: 0.67, blue: 0.91) // #3DAAE8
    let darkBlue = Color(red: 0.22, green: 0.60, blue: 0.82) // #3799D1

    @State private var hovered: Bool = false
    var width: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .fontWeight(.medium)
            .frame(width: width, height: 32)
            .padding(.horizontal, 6)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(hovered ? lightBlue.opacity(0.85) : lightBlue)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(hovered ? darkBlue.opacity(0.6) : darkBlue, lineWidth: 3)
                }
            )
            .cornerRadius(8)
            .shadow(color: .primary.opacity(0.08), radius: 1, x: 0, y: configuration.isPressed ? 0 : (hovered ? 3 : 1))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                withAnimation {
                    self.hovered = hovering
                }
            }
    }
}

// Preview
struct ButtonPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Primary Button", action: {})
            SecondaryButton(title: "Secondary Button", action: {})
            CompactButton(title: "Compact Button", action: {})
            CompactPrimaryButton(title: "Compact Primary Button", action: {})
        }
        .padding()
    }
}
