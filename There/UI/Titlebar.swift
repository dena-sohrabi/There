import SwiftUI

struct Titlebar: View {
    @EnvironmentObject var router: Router
    @State var hovered: Bool = false
    var body: some View {
        HStack(alignment: .center) {
            Button {
                router.cleanActiveRoute()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .padding(4)
                    .background(hovered ? Color(NSColor.separatorColor).opacity(0.8) : .clear)
                    .cornerRadius(6)
                    .onHover { hovered in
                        withAnimation {
                            self.hovered = hovered
                        }
                    }
            }
            .buttonStyle(.plain)

            switch router.activeRoute {
            case .addTimezone:
                Text("🗺️")
                    .font(.callout)
                Text("Add Time Zone")
                    .font(.body)
                    .fontWeight(.medium)
            case .editTimeZone:
                Text("✍️")
                    .font(.callout)
                Text("Edit Time Zone")
                    .font(.body)
                    .fontWeight(.medium)
            case .mainView:
                EmptyView()
            }
        }
    }
}

#Preview {
    Titlebar()
        .padding()
}
