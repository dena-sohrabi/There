import SwiftUI

struct StyledLabel: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
    }
}

#Preview {
    StyledLabel(title: "Name")
}
