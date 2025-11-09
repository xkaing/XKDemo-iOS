//
//  MomentsService.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import Foundation
import Supabase

/// 动态数据模型，对应 Supabase moments 表
struct Moment: Codable, Identifiable {
    let id: UUID?
    let userName: String
    let userAvatarUrl: String?
    let publishTime: String
    let contentText: String
    let contentImgUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case userAvatarUrl = "user_avatar_url"
        case publishTime = "publish_time"
        case contentText = "content_text"
        case contentImgUrl = "content_img_url"
    }
    
    // 默认初始化方法（用于创建新实例）
    init(
        id: UUID? = nil,
        userName: String,
        userAvatarUrl: String?,
        publishTime: String,
        contentText: String,
        contentImgUrl: String?
    ) {
        self.id = id
        self.userName = userName
        self.userAvatarUrl = userAvatarUrl
        self.publishTime = publishTime
        self.contentText = contentText
        self.contentImgUrl = contentImgUrl
    }
    
    // 自定义解码，处理可能的类型不匹配
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // id 可能是 UUID 字符串或 UUID
        var decodedId: UUID?
        if let idString = try? container.decode(String.self, forKey: .id) {
            decodedId = UUID(uuidString: idString)
        } else if let idUUID = try? container.decode(UUID.self, forKey: .id) {
            decodedId = idUUID
        }
        self.id = decodedId
        
        self.userName = try container.decode(String.self, forKey: .userName)
        self.userAvatarUrl = try container.decodeIfPresent(String.self, forKey: .userAvatarUrl)
        self.contentText = try container.decode(String.self, forKey: .contentText)
        self.contentImgUrl = try container.decodeIfPresent(String.self, forKey: .contentImgUrl)
        
        // publish_time 可能是 Date 或 String，统一转换为 String
        if let date = try? container.decode(Date.self, forKey: .publishTime) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.publishTime = formatter.string(from: date)
        } else {
            self.publishTime = try container.decode(String.self, forKey: .publishTime)
        }
    }
    
    // 自定义编码
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userName, forKey: .userName)
        try container.encodeIfPresent(userAvatarUrl, forKey: .userAvatarUrl)
        try container.encode(publishTime, forKey: .publishTime)
        try container.encode(contentText, forKey: .contentText)
        try container.encodeIfPresent(contentImgUrl, forKey: .contentImgUrl)
    }
}

/// 动态服务，管理 Supabase moments 表的操作
class MomentsService {
    static let shared = MomentsService()
    private let supabase = SupabaseManager.shared.client
    
    private init() {}
    
    /// 获取所有动态，按发布时间倒序排列
    func fetchMoments() async throws -> [Moment] {
        do {
            let moments: [Moment] = try await supabase
                .from("moments")
                .select()
                .order("publish_time", ascending: false)
                .execute()
                .value
            
            print("✅ 成功获取 \(moments.count) 条动态")
            return moments
        } catch {
            print("❌ 获取动态失败: \(error)")
            if let decodingError = error as? DecodingError {
                print("📋 解码错误详情: \(decodingError)")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("类型不匹配: 期望 \(type), 上下文: \(context)")
                case .valueNotFound(let type, let context):
                    print("值未找到: 类型 \(type), 上下文: \(context)")
                case .keyNotFound(let key, let context):
                    print("键未找到: \(key), 上下文: \(context)")
                case .dataCorrupted(let context):
                    print("数据损坏: \(context)")
                @unknown default:
                    print("未知解码错误")
                }
            }
            throw error
        }
    }
    
    /// 创建新动态
    func createMoment(
        userName: String,
        userAvatarUrl: String?,
        contentText: String,
        contentImgUrl: String?
    ) async throws -> Moment {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let publishTime = formatter.string(from: Date())
        
        let newMoment = Moment(
            id: nil,
            userName: userName,
            userAvatarUrl: userAvatarUrl,
            publishTime: publishTime,
            contentText: contentText,
            contentImgUrl: contentImgUrl
        )
        
        do {
            let response: Moment = try await supabase
                .from("moments")
                .insert(newMoment)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ 成功创建动态")
            return response
        } catch {
            print("❌ 创建动态失败: \(error)")
            throw error
        }
    }
}

