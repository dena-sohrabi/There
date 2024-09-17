import Combine
import Foundation
import GRDB

enum SortOrder {
    case timeAscending
    case timeDescending
}

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

    func sortEntries(by order: SortOrder) {
        switch order {
        case .timeAscending:
            entries.sort { $0.timeDifference.hours < $1.timeDifference.hours }
        case .timeDescending:
            entries.sort { $0.timeDifference.hours > $1.timeDifference.hours }
        }
    }
}
