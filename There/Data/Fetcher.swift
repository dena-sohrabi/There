import Combine
import Foundation
import GRDB

class Fetcher: ObservableObject {
    @Published var entries: [Entry] = []
    @Published var getEntries: AnyCancellable?
    var database: AppDatabase = .shared

    init() {
        getEntries = ValueObservation.tracking { db in
            try Entry.fetchAll(db)
        }
        .publisher(in: database.dbWriter, scheduling: .immediate)
        .sink(
            receiveCompletion: { _ in /* ignore error */ },
            receiveValue: { [weak self] entries in
                self?.entries = entries
            }
        )
    }
}
