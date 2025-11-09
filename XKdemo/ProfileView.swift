//
//  ProfileView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showEditProfile = false
    @State private var editingNickname = ""
    @State private var editingAvatarUrl = ""
    @State private var isUpdating = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 账号信息卡片
                    VStack(spacing: 16) {
                        // 头像 - 显示用户头像或默认图标
                        Group {
                            if !authManager.userAvatarUrl.isEmpty,
                               let avatarUrl = URL(string: authManager.userAvatarUrl) {
                                AsyncImage(url: avatarUrl) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
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
                    
                    // 编辑资料按钮
                    Button(action: {
                        editingNickname = authManager.userNickname
                        editingAvatarUrl = authManager.userAvatarUrl
                        showEditProfile = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("编辑资料")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.blue)
                        .background(Color(.systemBackground))
                    }
                    .padding(.top, 20)
                    
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
                    .padding(.top, 12)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("我的")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    nickname: $editingNickname,
                    avatarUrl: $editingAvatarUrl,
                    isUpdating: $isUpdating,
                    errorMessage: $errorMessage,
                    onSave: {
                        await updateProfile()
                    },
                    onCancel: {
                        showEditProfile = false
                    }
                )
            }
        }
    }
    
    private func updateProfile() async {
        isUpdating = true
        errorMessage = nil
        
        do {
            try await authManager.updateProfile(
                nickname: editingNickname.isEmpty ? nil : editingNickname,
                avatarUrl: editingAvatarUrl.isEmpty ? nil : editingAvatarUrl
            )
            showEditProfile = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isUpdating = false
    }
}

struct EditProfileView: View {
    @Binding var nickname: String
    @Binding var avatarUrl: String
    @Binding var isUpdating: Bool
    @Binding var errorMessage: String?
    let onSave: () async -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("昵称", text: $nickname)
                    TextField("头像 URL", text: $avatarUrl)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onCancel()
                    }
                    .disabled(isUpdating)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            await onSave()
                        }
                    }
                    .disabled(isUpdating || nickname.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}

