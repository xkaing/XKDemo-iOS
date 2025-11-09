//
//  ComposePostView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI
import PhotosUI

struct ComposePostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    var onPostCreated: (() -> Void)?
    
    @State private var content: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isPublishing = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 文字输入区域
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .padding(4)
                        
                        // 占位符文本
                        if content.isEmpty {
                            Text("请输入文字")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // 图片选择区域
                    if let image = selectedImage {
                        VStack(alignment: .leading, spacing: 12) {
                            // 显示选中的图片
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                
                                // 删除按钮
                                Button(action: {
                                    selectedImage = nil
                                    selectedPhoto = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                }
                                .padding(8)
                            }
                        }
                    }
                    
                    // 图片选择按钮
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                            Text("添加照片")
                                .font(.system(size: 17))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        Task {
                            if let newItem = newItem {
                                if let data = try? await newItem.loadTransferable(type: Data.self) {
                                    if let image = UIImage(data: data) {
                                        selectedImage = image
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("发布动态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("发布") {
                        publishPost()
                    }
                    .disabled(content.isEmpty || isPublishing)
                }
            }
            .alert("错误", isPresented: .constant(errorMessage != nil)) {
                Button("确定", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private func publishPost() {
        guard !content.isEmpty else { return }
        
        isPublishing = true
        errorMessage = nil
        
        Task {
            do {
                // 获取用户信息
                let userName = authManager.userNickname.isEmpty ? "用户" : authManager.userNickname
                let userAvatarUrl: String? = nil // 暂时使用默认头像，后续可以上传头像
                
                // 如果有图片，这里应该上传到 Supabase Storage 并获取 URL
                // 目前暂时使用空值，后续可以实现图片上传功能
                let contentImgUrl: String? = nil
                
                // 保存到 Supabase
                _ = try await MomentsService.shared.createMoment(
                    userName: userName,
                    userAvatarUrl: userAvatarUrl,
                    contentText: content,
                    contentImgUrl: contentImgUrl
                )
                
                await MainActor.run {
                    isPublishing = false
                    dismiss()
                    // 通知父视图刷新列表
                    onPostCreated?()
                }
            } catch {
                await MainActor.run {
                    isPublishing = false
                    errorMessage = "发布失败: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ComposePostView()
        .environmentObject(AuthManager())
}

