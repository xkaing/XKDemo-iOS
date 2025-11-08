//
//  ContentView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("主页", systemImage: "house.fill")
                }
                .tag(0)
            
            CommunityView()
                .tabItem {
                    Label("社区", systemImage: "person.3.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.circle.fill")
                }
                .tag(2)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
