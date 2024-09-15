import SwiftUI

struct Titlebar: View {
    @EnvironmentObject var router: Router
    @State var hovered: Bool = false
    var body: some View {
        Button {
            router.cleanActiveRoute()
        } label: {
            HStack(alignment: .center) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.secondary)
                    .font(.body)
                switch router.activeRoute {
                case .addTimezone:
                    Text("🗺️")
                        .font(.callout)
                    Text("Add Time Zone")
                        .font(.body)
                        .fontWeight(.medium)
                case .mainView:
                    EmptyView()
                }
            }
        }
        .buttonStyle(.plain)
        .padding(2)
        .background(hovered ? Color(NSColor.separatorColor).opacity(0.8) : .clear)
        .cornerRadius(6)
        .onHover { hovered in
            withAnimation {
                self.hovered = hovered
            }
        }
    }
}

#Preview {
    Titlebar()
        .padding()
}
