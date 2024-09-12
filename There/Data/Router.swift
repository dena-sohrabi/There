import SwiftUI

enum Route {
    case addTimezone
    case mainView
}

class Router: ObservableObject {
    @Published var activeRoute: Route = .mainView

    func setActiveRoute(to route: Route) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            activeRoute = route
        }
    }

    func cleanActiveRoute() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            activeRoute = .mainView
        }
    }

    init() {
        print("🔎 Nav init")
    }
}
