//
//  XKdemoApp.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

@main
struct XKdemoApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                ContentView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
