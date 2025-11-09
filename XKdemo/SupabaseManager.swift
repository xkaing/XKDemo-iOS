//
//  SupabaseManager.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import Foundation
import Supabase

/// Supabase 客户端管理器
class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // 从环境变量或配置中读取 Supabase URL 和 Key
        // 注意：在生产环境中，应该使用更安全的方式存储这些敏感信息
        let supabaseURL = URL(string: "https://faltruhdczvgyfltmick.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhbHRydWhkY3p2Z3lmbHRtaWNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2NzI1NDQsImV4cCI6MjA3ODI0ODU0NH0.qNbVMxGAd0nW75AGB4lqnVaK30lRRyD7FAaMiW5BZuA"
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}

