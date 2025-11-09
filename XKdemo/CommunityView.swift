//
//  CommunityView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

struct CommunityView: View {
    @Binding var showComposeView: Bool
    @EnvironmentObject var authManager: AuthManager
    
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("加载失败")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("重试") {
                            loadPosts()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 50)
                } else if posts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("还没有动态")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    VStack(spacing: 16) {
                        ForEach(posts) { post in
                            PostCard(post: post)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .scrollIndicators(.visible)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("社区")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showComposeView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showComposeView) {
                ComposePostView(onPostCreated: {
                    loadPosts()
                })
            }
            .refreshable {
                await loadPostsAsync()
            }
            .task {
                await loadPostsAsync()
            }
        }
    }
    
    /// 加载动态列表
    private func loadPosts() {
        Task {
            await loadPostsAsync()
        }
    }
    
    /// 异步加载动态列表
    private func loadPostsAsync() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let moments = try await MomentsService.shared.fetchMoments()
            await MainActor.run {
                self.posts = moments.map { Post(from: $0) }
                self.isLoading = false
                print("✅ 成功加载 \(moments.count) 条动态")
            }
        } catch {
            await MainActor.run {
                // 提供更友好的错误信息
                var errorText = error.localizedDescription
                
                // 检查是否是表不存在或权限问题
                if let nsError = error as NSError? {
                    if let errorDescription = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
                        errorText = errorDescription
                    }
                    
                    // 检查是否是网络错误
                    if nsError.domain == NSURLErrorDomain {
                        errorText = "网络连接失败，请检查网络设置"
                    }
                }
                
                // 检查是否是解码错误
                if error is DecodingError {
                    errorText = "数据格式错误，请检查数据库表结构是否正确"
                }
                
                self.errorMessage = errorText
                self.isLoading = false
                print("❌ 加载动态失败: \(error)")
            }
        }
    }
}

#Preview {
    CommunityView(showComposeView: .constant(false))
        .environmentObject(AuthManager())
}

