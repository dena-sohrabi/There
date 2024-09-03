import SwiftUI

struct PrimaryButton: View {
    let lightBlue = Color(red: 0.24, green: 0.67, blue: 0.91) // #3DAAE8
    let darkBlue = Color(red: 0.22, green: 0.60, blue: 0.82) // #3799D1

    var body: some View {
        Button {
        } label: {
            Text("Continue")
                .foregroundColor(.white)
                .fontWeight(.medium)
                .frame(width: 200, height: 32)
                .background(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .stroke(darkBlue, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(lightBlue)
        .cornerRadius(12)
        .shadow(color: .primary.opacity(0.08), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    PrimaryButton()
        .padding()
}

struct SecondaryButton: View {
    let white = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF
    let lightGray = Color(red: 0.86, green: 0.86, blue: 0.86) // #DCDCDC

    var body: some View {
        Button {
        } label: {
            Text("Continue")
                .foregroundColor(.primary.opacity(0.8))
                .fontWeight(.medium)
                .frame(width: 200, height: 32)
                .background(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .stroke(lightGray, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(white)
        .cornerRadius(12)
        .shadow(color: .primary.opacity(0.08), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    SecondaryButton()
        .padding()
}
