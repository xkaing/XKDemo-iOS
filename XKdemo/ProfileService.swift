//
//  ProfileService.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import Foundation
import Supabase

/// 用户资料数据模型，对应 Supabase profiles 表
struct Profile: Codable, Identifiable {
    let id: UUID
    let nickname: String?
    let avatarUrl: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // 默认初始化方法（用于创建新实例）
    init(
        id: UUID,
        nickname: String? = nil,
        avatarUrl: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.nickname = nickname
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // 自定义解码，处理可能的类型不匹配
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // id 可能是 UUID 字符串或 UUID
        var decodedId: UUID
        if let idString = try? container.decode(String.self, forKey: .id) {
            guard let uuid = UUID(uuidString: idString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .id,
                    in: container,
                    debugDescription: "Invalid UUID string"
                )
            }
            decodedId = uuid
        } else {
            decodedId = try container.decode(UUID.self, forKey: .id)
        }
        self.id = decodedId
        
        self.nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        
        // 时间戳可能是 Date 或 String，统一转换为 String
        if let date = try? container.decode(Date.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.createdAt = formatter.string(from: date)
        } else {
            self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        }
        
        if let date = try? container.decode(Date.self, forKey: .updatedAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.updatedAt = formatter.string(from: date)
        } else {
            self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        }
    }
}

/// 用户资料服务，管理 Supabase profiles 表的操作
class ProfileService {
    static let shared = ProfileService()
    private let supabase = SupabaseManager.shared.client
    
    private init() {}
    
    /// 获取指定用户的资料
    /// - Parameter userId: 用户 ID
    /// - Returns: 用户资料，如果不存在则返回 nil
    func fetchProfile(userId: UUID) async throws -> Profile? {
        do {
            let profile: Profile? = try await supabase
                .from(SupabaseConfig.profilesTable)
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            if let profile = profile {
                print("✅ 成功获取用户资料: \(userId)")
            } else {
                print("ℹ️ 用户资料不存在: \(userId)")
            }
            return profile
        } catch {
            // 如果是 404 错误（记录不存在），返回 nil 而不是抛出错误
            if let error = error as? NSError,
               let errorDescription = error.userInfo[NSLocalizedDescriptionKey] as? String,
               errorDescription.contains("No rows") || errorDescription.contains("not found") {
                print("ℹ️ 用户资料不存在: \(userId)")
                return nil
            }
            print("❌ 获取用户资料失败: \(error)")
            throw error
        }
    }
    
    /// 创建用户资料
    /// - Parameters:
    ///   - userId: 用户 ID
    ///   - nickname: 昵称
    ///   - avatarUrl: 头像 URL
    /// - Returns: 创建的用户资料
    func createProfile(
        userId: UUID,
        nickname: String? = nil,
        avatarUrl: String? = nil
    ) async throws -> Profile {
        let newProfile = Profile(
            id: userId,
            nickname: nickname,
            avatarUrl: avatarUrl
        )
        
        do {
            let response: Profile = try await supabase
                .from(SupabaseConfig.profilesTable)
                .insert(newProfile)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ 成功创建用户资料: \(userId)")
            return response
        } catch {
            print("❌ 创建用户资料失败: \(error)")
            throw error
        }
    }
    
    /// 更新用户资料
    /// - Parameters:
    ///   - userId: 用户 ID
    ///   - nickname: 昵称（可选）
    ///   - avatarUrl: 头像 URL（可选）
    /// - Returns: 更新后的用户资料
    func updateProfile(
        userId: UUID,
        nickname: String? = nil,
        avatarUrl: String? = nil
    ) async throws -> Profile {
        var updateData: [String: AnyJSON] = [:]
        
        if let nickname = nickname {
            updateData["nickname"] = .string(nickname)
        }
        if let avatarUrl = avatarUrl {
            updateData["avatar_url"] = .string(avatarUrl)
        }
        
        guard !updateData.isEmpty else {
            throw NSError(
                domain: "ProfileService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "没有要更新的数据"]
            )
        }
        
        do {
            let response: Profile = try await supabase
                .from(SupabaseConfig.profilesTable)
                .update(updateData)
                .eq("id", value: userId.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ 成功更新用户资料: \(userId)")
            return response
        } catch {
            print("❌ 更新用户资料失败: \(error)")
            throw error
        }
    }
    
    /// 获取或创建用户资料（如果不存在则创建）
    /// - Parameters:
    ///   - userId: 用户 ID
    ///   - nickname: 默认昵称（如果资料不存在）
    ///   - avatarUrl: 默认头像 URL（如果资料不存在）
    /// - Returns: 用户资料
    func getOrCreateProfile(
        userId: UUID,
        nickname: String? = nil,
        avatarUrl: String? = nil
    ) async throws -> Profile {
        // 先尝试获取
        if let profile = try await fetchProfile(userId: userId) {
            return profile
        }
        
        // 如果不存在，则创建
        return try await createProfile(userId: userId, nickname: nickname, avatarUrl: avatarUrl)
    }
}

