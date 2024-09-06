// LeftPanel.swift

import SwiftUI

struct LeftPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("Logo")
            Text("Hey There!")
                .font(.largeTitle)
                .fontWeight(.bold)
            DateTimeInfo()
        }
    }
}

struct DateTimeInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                DateTimeLabel(date: Date.now, format: .dateTime.timeZone() , color: .green)
                DateTimeLabel(date: Date.now, format: .dateTime.hour().minute(), color: .cyan)
            }
            HStack {
                DateTimeLabel(text: TimeZone.current.identifier, color: .yellow)
                DateTimeLabel(date: Date.now, format: .dateTime.weekday(), color: .pink)
            }
        }
    }
}

struct DateTimeLabel: View {
    var date: Date?
    var text: String?
    var format: Date.FormatStyle?
    var color: Color

    init(date: Date? = nil, text: String? = nil, format: Date.FormatStyle? = nil, color: Color = .green) {
        self.date = date
        self.text = text
        self.format = format
        self.color = color
    }

    var body: some View {
        Group {
            if let date = date, let format = format {
                Text(date, format: format)
            } else if let text = text {
                Text(text)
            } else {
                Text("Invalid input")
            }
        }
        .monospaced()
        .padding(4)
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }
}
