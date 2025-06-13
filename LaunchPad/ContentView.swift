//
//  ContentView.swift
//  LaunchPad
//
//  Created by Chu Feng on 13/6/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var apps: [AppModel] = []
    @State private var searchText: String = ""

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                SearchBarView(searchText: $searchText)
                    .padding(.top, 20)
                    .frame(width: 200)
                
                AppGridView(apps: $apps, searchText: $searchText)
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.vertical, geometry.size.height * 0.05)
            }
            .contentShape(Rectangle())
            .background(Color.black.opacity(0.7))
            .onTapGesture {
                print("Background tapped")
                NSApplication.shared.hide(nil)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            loadApps()
        }
    }

    private func loadApps() {
        apps = fetchApplications()
    }
}
