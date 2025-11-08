//
//  ProfileView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 账号信息卡片
                    VStack(spacing: 16) {
                        // 头像
                        AsyncImage(url: URL(string: User.shared.avatar)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // 昵称
                        Text(User.shared.name)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color(.systemBackground))
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("我的")
        }
    }
}

#Preview {
    ProfileView()
}

