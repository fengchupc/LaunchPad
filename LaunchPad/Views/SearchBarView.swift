import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search applications...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(8)
        .frame(width: 200) // 固定搜索栏宽度
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}
