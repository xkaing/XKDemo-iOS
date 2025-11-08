//
//  Post.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import Foundation

struct Post: Identifiable {
    let id = UUID()
    let userName: String
    let userAvatar: String
    let publishTime: String
    let content: String
    let imageUrl: String? // 可选，如果有图片URL就显示
}

