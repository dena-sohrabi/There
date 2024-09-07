import SwiftUI

struct PrimaryButton: View {
    let lightBlue = Color(red: 0.24, green: 0.67, blue: 0.91) // #3DAAE8
    let darkBlue = Color(red: 0.22, green: 0.60, blue: 0.82) // #3799D1

    @State private var hovered: Bool = false
    @State private var isPressed: Bool = false

    var title: String
    var action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .foregroundColor(.white)
                .fontWeight(.medium)
                .frame(width: 200, height: 32)
                .background(
                    RoundedRectangle(
                        cornerRadius: 8,
                        style: .continuous
                    )
                    .stroke(hovered ? darkBlue.opacity(0.6) : darkBlue, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(hovered ? lightBlue.opacity(0.85) : lightBlue)
        .onHover(perform: { hovered in
            withAnimation {
                self.hovered = hovered
            }
        })
        .cornerRadius(8)
        .shadow(color: .primary.opacity(0.08), radius: 1, x: 0, y: isPressed ? 0 : (hovered ? 3 : 1))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in self.isPressed = true }
                .onEnded { _ in

                    self.isPressed = false

                    self.action()
                }
        )
    }
}

#Preview {
    PrimaryButton(title: "Continue", action: {})
        .padding()
}

struct SecondaryButton: View {
    let white = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF
    let lightGray = Color(red: 0.86, green: 0.86, blue: 0.86) // #DCDCDC

    @State private var hovered: Bool = false
    @State private var isPressed: Bool = false

    var title: String
    var action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .foregroundColor(.primary.opacity(0.8))
                .fontWeight(.medium)
                .frame(width: 200, height: 32)
                .background(
                    RoundedRectangle(
                        cornerRadius: 8,
                        style: .continuous
                    )
                    .stroke(hovered ? lightGray.opacity(0.6) : lightGray, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(hovered ? white.opacity(0.85) : white)
        .onHover { hovering in
            withAnimation {
                self.hovered = hovering
            }
        }
        .cornerRadius(8)
        .shadow(color: .primary.opacity(0.08), radius: 1, x: 0, y: isPressed ? 0 : (hovered ? 3 : 1))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in self.isPressed = true }
                .onEnded { _ in
                    self.isPressed = false
                    self.action()
                }
        )
    }
}

#Preview {
    SecondaryButton(title: "Continue", action: {})
        .padding()
}

struct CompactButton: View {
    let lightGray = Color(red: 0.86, green: 0.86, blue: 0.86) // #DCDCDC

    @State private var hovered: Bool = false
    @State private var isPressed: Bool = false

    var title: String
    var action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .padding(.horizontal, 8)
                .foregroundColor(.primary)
                .fontWeight(.medium)
                .frame(height: 28)
//                .background(
//                    RoundedRectangle(
//                        cornerRadius: 8,
//                        style: .continuous
//                    )
//                    .stroke(hovered ? lightGray.opacity(0.4) : lightGray.opacity(0.6), lineWidth: 3)
//                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(hovered ? .white : .white.opacity(0.8))
        .onHover(perform: { hovered in
            withAnimation {
                self.hovered = hovered
            }
        })
        .cornerRadius(8)
        .shadow(color: .primary.opacity(0.04), radius: 1, x: 0, y: isPressed ? 0 : (hovered ? 2 : 1))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in self.isPressed = true }
                .onEnded { _ in

                    self.isPressed = false

                    self.action()
                }
        )
        .fixedSize()
    }
}

#Preview {
    CompactButton(title: "Continue", action: {})
        .padding()
}

struct CompactPrimaryButton: View {
    let lightBlue = Color(red: 0.24, green: 0.67, blue: 0.91) // #3DAAE8
    let darkBlue = Color(red: 0.22, green: 0.60, blue: 0.82) // #3799D1

    @State private var hovered: Bool = false
    @State private var isPressed: Bool = false
    var width: CGFloat = 232
    var title: String
    var action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .foregroundColor(.white)
                .fontWeight(.medium)
                .frame(width : width ,height: 32)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(
                        cornerRadius: 8,
                        style: .continuous
                    )
                    .stroke(hovered ? darkBlue.opacity(0.6) : darkBlue, lineWidth: 3)
                )
                .scaledToFill()
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(hovered ? lightBlue.opacity(0.85) : lightBlue)
        .onHover(perform: { hovered in
            withAnimation {
                self.hovered = hovered
            }
        })
        .cornerRadius(8)
        .shadow(color: .primary.opacity(0.08), radius: 1, x: 0, y: isPressed ? 0 : (hovered ? 3 : 1))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .scaledToFill()
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in self.isPressed = true }
                .onEnded { _ in

                    self.isPressed = false

                    self.action()
                }
        )
    }
}

#Preview {
    CompactPrimaryButton(title: "Continue", action: {})
        .padding()
}
