//
//  HomeView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding()
                
                Text("主页")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("主页")
        }
    }
}

#Preview {
    HomeView()
}

