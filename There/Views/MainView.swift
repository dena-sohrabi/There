import GRDB
import PostHog
import SwiftUI

struct MainView: View {
    @AppStorage("email") var email: String = ""
    @StateObject private var fetcher = Fetcher()
    @State private var sortOrder: SortOrder = .timeAscending
    @State private var sortedEntries: [Entry] = []
    @Environment(\.database) var database: AppDatabase
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: Router
    @State private var currentDate = Date()
    @State private var isAtBottom: Bool = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: sortedEntries.isEmpty ? .center : .leading, spacing: 2) {
            if sortedEntries.isEmpty {
                Spacer()
                EmptyTimezoneView()
                Spacer()
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedEntries) { entry in
                            EntryRow(entry: entry)
                                .contextMenu {
                                    Button("Edit") {
                                        router.setActiveRoute(to: .editTimeZone(entryId: entry.id))
                                    }
                                    Button("Delete", role: .destructive) {
                                        deleteEntry(entry)
                                    }
                                }

                                .id(entry.id)
                        }
                        .animation(.easeInOut(duration: 0.1), value: sortedEntries.count)
                        Color.clear
                            .frame(height: 2)
                            .onAppear {
                                isAtBottom = false
                            }
                            .onDisappear {
                                isAtBottom = true
                            }
                    }
                    .padding(.horizontal, 6)
                }
                .scrollIndicators(.hidden)
            }
            BottomBarView(isAtBottom: $isAtBottom, sortOrder: $sortOrder)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 6)
        .onAppear {
            sortEntries()
        }
        .onChange(of: sortOrder) { _ in
            sortEntries()
        }
        .onChange(of: fetcher.entries) { _ in
            sortEntries()
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }

    private func sortEntries() {
        switch sortOrder {
        case .timeAscending:
            sortedEntries = fetcher.entries.sorted { $0.timeDifference.hours < $1.timeDifference.hours }
        case .timeDescending:
            sortedEntries = fetcher.entries.sorted { $0.timeDifference.hours > $1.timeDifference.hours }
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
                print("Can't delete entry \(error)")
            }
        }
    }
}

#Preview {
    MainView()
        .frame(width: 400, height: 400)
}
