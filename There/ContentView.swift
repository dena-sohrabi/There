import SwiftUI

struct ContentView: View {
    @EnvironmentObject var router: Router
    var body: some View {
        switch router.activeRoute {
        case .mainView:
            MainView()
        case .addTimezone:
            AddTimezone()
                .transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 300, height: 400)
}
