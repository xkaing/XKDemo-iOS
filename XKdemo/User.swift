//
//  User.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import Foundation

struct User {
    static let shared = User()
    
    let avatar: String = "https://picsum.photos/id/323/100/100"
    let name: String = "XKAI"
    
    private init() {}
}

