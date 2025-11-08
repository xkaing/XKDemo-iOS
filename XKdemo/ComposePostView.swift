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
    @Binding var posts: [Post]
    
    @State private var content: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isPublishing = false
    
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
        }
    }
    
    private func publishPost() {
        guard !content.isEmpty else { return }
        
        isPublishing = true
        
        // 生成当前时间
        let formatter = DateFormatter()
        formatter.dateFormat = "M-d HH:mm"
        let currentTime = formatter.string(from: Date())
        
        // 如果有图片，这里我们使用一个随机的picsum URL
        // 在实际应用中，这里应该上传图片到服务器并获取URL
        let imageUrl: String? = selectedImage != nil ? "https://picsum.photos/id/\(Int.random(in: 200...300))/400/300" : nil
        
        // 创建新动态，使用账号信息
        let newPost = Post(
            userName: User.shared.name,
            userAvatar: User.shared.avatar,
            publishTime: currentTime,
            content: content,
            imageUrl: imageUrl
        )
        
        // 插入到列表最上面
        posts.insert(newPost, at: 0)
        
        // 延迟一下，让用户看到发布成功的效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPublishing = false
            dismiss()
        }
    }
}

#Preview {
    ComposePostView(posts: .constant([]))
}

