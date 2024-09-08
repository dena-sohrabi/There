import GRDB
import SwiftUI

struct ContentView: View {
    @AppStorage("email") var email: String = ""
    @StateObject private var locationManager = LocationManager()
    @StateObject private var fetcher = Fetcher()
    @State private var sortOrder: SortOrder = .dayPeriodDescending
    @State private var sortedEntries: [Entry] = []
    @Environment(\.database) var database: AppDatabase

    var body: some View {
        VStack(alignment: sortedEntries.isEmpty ? .center : .leading, spacing: 2) {
            if sortedEntries.isEmpty {
                EmptyTimezoneView()
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedEntries) { entry in
                            EntryRow(entry: entry)
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        deleteEntry(entry)
                                    }
                                }
                        }
                        .animation(.easeInOut(duration: 0.1), value: sortedEntries.count)
                    }
                    .padding(.horizontal, 6)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            BottomBarView()
        }
        .onAppear {
            locationManager.checkLocationAuthorization()
            sortEntries()
        }
        .onChange(of: sortOrder) { _ in
            sortEntries()
        }
        .onChange(of: fetcher.entries) { _ in
            sortEntries()
        }
        .environmentObject(locationManager)
    }

    private func sortEntries() {
        switch sortOrder {
        case .dayPeriodAscending:
            sortedEntries = fetcher.entries.sorted { $0.timeDifference.dayPeriod.rawValue < $1.timeDifference.dayPeriod.rawValue }
        case .dayPeriodDescending:
            sortedEntries = fetcher.entries.sorted { $0.timeDifference.dayPeriod.rawValue > $1.timeDifference.dayPeriod.rawValue }
        }
    }

    private func deleteEntry(_ entry: Entry) {
        Task {
            do {
                try await database.dbWriter.write { db in
                    let fetchedEntry = try Entry.fetchOne(db, id: entry.id)
                    try fetchedEntry?.delete(db)
                }
            } catch {
                print("Can't delete \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 300, height: 400)
}
