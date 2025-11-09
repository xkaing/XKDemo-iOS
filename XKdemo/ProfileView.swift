//
//  ProfileView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 账号信息卡片
                    VStack(spacing: 16) {
                        // 头像 - 使用默认图标
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // 昵称 - 使用 Supabase 登录后的昵称
                        Text(authManager.userNickname.isEmpty ? "用户" : authManager.userNickname)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // 邮箱 - 使用 Supabase 登录后的邮箱
                        if !authManager.userEmail.isEmpty {
                            Text(authManager.userEmail)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color(.systemBackground))
                    
                    // 登出按钮
                    Button(action: {
                        authManager.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("退出登录")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.red)
                        .background(Color(.systemBackground))
                    }
                    .padding(.top, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("我的")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}

