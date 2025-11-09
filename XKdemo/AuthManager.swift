//
//  AuthManager.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import Foundation
import SwiftUI
import Combine
import Supabase

/// 认证管理器，负责处理用户登录、注册和会话管理
class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userEmail: String = ""
    @Published var userNickname: String = ""
    @Published var userId: String = ""
    
    private let supabase = SupabaseManager.shared.client
    
    init() {
        // 从 UserDefaults 读取登录状态
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        self.userNickname = UserDefaults.standard.string(forKey: "userNickname") ?? ""
        self.userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        
        // 检查是否有有效的会话
        Task {
            await checkSession()
        }
    }
    
    /// 检查当前会话是否有效
    @MainActor
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            // 会话有效，更新用户信息
            await loadUserInfo(userId: session.user.id.uuidString)
            self.isLoggedIn = true
        } catch {
            print("检查会话失败: \(error.localizedDescription)")
            self.isLoggedIn = false
        }
    }
    
    /// 使用邮箱和密码登录
    func signIn(email: String, password: String) async throws {
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            
            await MainActor.run {
                self.userId = session.user.id.uuidString
                self.userEmail = session.user.email ?? email
                self.isLoggedIn = true
                
                // 保存到 UserDefaults
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                UserDefaults.standard.set(self.userId, forKey: "userId")
            }
            
            // 加载用户信息（包括昵称）
            await loadUserInfo(userId: self.userId)
        } catch {
            throw error
        }
    }
    
    /// 使用邮箱和密码注册新用户
    func signUp(email: String, password: String, nickname: String) async throws {
        do {
            // 根据 Supabase Swift SDK 官方文档，使用 data 参数传递用户元数据
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "nickname": AnyJSON.string(nickname),
                    "full_name": AnyJSON.string(nickname)
                ]
            )
            
            // authResponse.user 不是可选类型，直接使用
            let user = authResponse.user
            
            await MainActor.run {
                self.userId = user.id.uuidString
                self.userEmail = email
                self.userNickname = nickname
                self.isLoggedIn = true
                
                // 保存到 UserDefaults
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                UserDefaults.standard.set(self.userNickname, forKey: "userNickname")
                UserDefaults.standard.set(self.userId, forKey: "userId")
            }
        } catch {
            throw error
        }
    }
    
    /// 加载用户信息
    @MainActor
    private func loadUserInfo(userId: String) async {
        do {
            // 从 Supabase 获取用户信息
            let user = try await supabase.auth.user()
            
            // 从用户元数据中获取昵称
            if let nickname = user.userMetadata["nickname"] as? String {
                self.userNickname = nickname
                UserDefaults.standard.set(nickname, forKey: "userNickname")
            } else if let fullName = user.userMetadata["full_name"] as? String {
                self.userNickname = fullName
                UserDefaults.standard.set(fullName, forKey: "userNickname")
            }
            
            // 更新邮箱信息
            if let email = user.email {
                self.userEmail = email
                UserDefaults.standard.set(email, forKey: "userEmail")
            }
        } catch {
            print("加载用户信息失败: \(error.localizedDescription)")
        }
    }
    
    /// 登出
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            
            await MainActor.run {
                self.userEmail = ""
                self.userNickname = ""
                self.userId = ""
                self.isLoggedIn = false
                
                // 清除 UserDefaults
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                UserDefaults.standard.removeObject(forKey: "userEmail")
                UserDefaults.standard.removeObject(forKey: "userNickname")
                UserDefaults.standard.removeObject(forKey: "userId")
            }
        } catch {
            print("登出失败: \(error.localizedDescription)")
        }
    }
    
    /// 兼容旧版本的登录方法（保留用于向后兼容）
    func login(email: String, nickname: String? = nil) {
        self.userEmail = email
        if let nickname = nickname {
            self.userNickname = nickname
            UserDefaults.standard.set(nickname, forKey: "userNickname")
        }
        self.isLoggedIn = true
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(email, forKey: "userEmail")
    }
    
    /// 兼容旧版本的登出方法
    func logout() {
        Task {
            await signOut()
        }
    }
}

