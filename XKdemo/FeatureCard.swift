//
//  FeatureCard.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI

struct FeatureCard: View {
    let title: String
    let description: String
    let gradientColors: [Color]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 渐变色背景
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            
            // 左下角文字内容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: 360, height: 200)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    VStack {
        FeatureCard(
            title: "开直播",
            description: "虚拟开播端调试",
            gradientColors: [
                Color(red: 0.5, green: 0.2, blue: 0.9),
                Color(red: 0.9, green: 0.3, blue: 0.6),
                Color(red: 1.0, green: 0.5, blue: 0.3),
                Color(red: 1.0, green: 0.7, blue: 0.2)
            ]
        )
        
        FeatureCard(
            title: "发动态",
            description: "don't BB",
            gradientColors: [
                Color(red: 0.2, green: 0.6, blue: 0.9),
                Color(red: 0.3, green: 0.8, blue: 0.7),
                Color(red: 0.4, green: 0.9, blue: 0.5),
                Color(red: 0.6, green: 1.0, blue: 0.4)
            ]
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

