import SwiftUI

enum Route {
    case addTimezone
    case mainView
}

class Router: ObservableObject {
    @Published var activeRoute: Route = .mainView

    func setActiveRoute(to route: Route) {
        withAnimation(.default) {
            activeRoute = route
        }
    }

    func cleanActiveRoute() {
        withAnimation(.default) {
            activeRoute = .mainView
        }
    }
}
