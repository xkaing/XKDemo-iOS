//
//  CommunityView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

struct CommunityView: View {
    @State private var showComposeView = false
    
    // Mock数据
    @State private var posts: [Post] = [
        Post(
            userName: "张三",
            userAvatar: "https://picsum.photos/id/11/50/50",
            publishTime: "11-8 14:30",
            content: "今天天气真好，适合出去走走！原本是形状各不相同的拼图，意外地拼成了完美的圆。",
            imageUrl: "https://picsum.photos/id/101/400/300"
        ),
        Post(
            userName: "李四",
            userAvatar: "https://picsum.photos/id/2/50/50",
            publishTime: "11-8 13:15",
            content: "分享一张美丽的风景照片，希望大家喜欢。如果说这趟知感浓度是百分之八十，那么往后的每一次回忆都会让这份情感浓度不只是一份深藏心里的能量。",
            imageUrl: "https://picsum.photos/id/102/400/300"
        ),
        Post(
            userName: "王五",
            userAvatar: "https://picsum.photos/id/3/50/50",
            publishTime: "11-8 12:00",
            content: "这是我们的同心季，也是给予前行的底气。纯文字动态，没有图片。",
            imageUrl: nil
        ),
        Post(
            userName: "赵六",
            userAvatar: "https://picsum.photos/id/4/50/50",
            publishTime: "11-7 20:45",
            content: "今天学到了很多新知识，感觉收获满满！",
            imageUrl: "https://picsum.photos/id/103/400/300"
        ),
        Post(
            userName: "孙七",
            userAvatar: "https://picsum.photos/id/5/50/50",
            publishTime: "11-7 18:20",
            content: "简单的生活，简单的快乐。",
            imageUrl: nil
        ),
        Post(
            userName: "周八",
            userAvatar: "https://picsum.photos/id/6/50/50",
            publishTime: "11-7 15:10",
            content: "新的一天开始了，加油！",
            imageUrl: "https://picsum.photos/id/104/400/300"
        ),
        Post(
            userName: "吴九",
            userAvatar: "https://picsum.photos/id/7/50/50",
            publishTime: "11-7 10:30",
            content: "分享一些生活感悟，希望大家都能找到属于自己的快乐。",
            imageUrl: nil
        ),
        Post(
            userName: "郑十",
            userAvatar: "https://picsum.photos/id/8/50/50",
            publishTime: "11-6 22:00",
            content: "晚上好，今天工作很充实。",
            imageUrl: "https://picsum.photos/id/115/400/300"
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(posts) { post in
                        PostCard(post: post)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
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
                ComposePostView(posts: $posts)
            }
        }
    }
}

#Preview {
    CommunityView()
}

