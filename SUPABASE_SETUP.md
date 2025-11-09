# Supabase 集成说明

本文档说明如何在 Xcode 项目中添加 Supabase Swift Package 依赖，并配置 Supabase 客户端。

## 步骤 1: 在 Xcode 中添加 Supabase Swift Package

1. 打开 Xcode 项目 `XKdemo.xcodeproj`

2. 在 Xcode 中，选择菜单：**File** > **Add Package Dependencies...**

3. 在搜索框中输入 Supabase Swift SDK 的 URL：
   ```
   https://github.com/supabase/supabase-swift
   ```

4. 点击 **Add Package**

5. 选择版本规则（建议选择 **Up to Next Major Version**，例如 `2.0.0`）

6. 在 **Add to Target** 中，确保勾选 **XKdemo** target

7. 点击 **Add Package** 完成添加

## 步骤 2: 配置 Supabase 项目

1. 访问 [Supabase 官网](https://supabase.com/) 并登录

2. 创建新项目或使用现有项目

3. 在项目设置中，进入 **Settings** > **API**

4. 复制以下信息：
   - **Project URL** (例如: `https://xxxxx.supabase.co`)
   - **anon public** key (anon/public 密钥)

## 步骤 3: 更新 SupabaseManager.swift

打开 `XKdemo/SupabaseManager.swift` 文件，将以下占位符替换为你的实际值：

```swift
let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
```

例如：
```swift
let supabaseURL = URL(string: "https://xxxxx.supabase.co")!
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## 步骤 4: 配置 Supabase 数据库（可选）

如果你需要在数据库中存储用户信息（如昵称），可以：

1. 在 Supabase Dashboard 中，进入 **Table Editor**

2. 创建一个 `profiles` 表（或使用 `auth.users` 表的元数据）

3. 或者，使用用户元数据（user_metadata）来存储昵称（当前实现方式）

## 步骤 5: 测试

1. 运行项目（Cmd + R）

2. 尝试注册新用户

3. 尝试登录

## 注意事项

- **安全性**：在生产环境中，不要将 Supabase 密钥硬编码在代码中。考虑使用：
  - 环境变量
  - Xcode 的 Build Configuration
  - 配置文件（不提交到 Git）

- **邮箱验证**：默认情况下，Supabase 可能需要邮箱验证。你可以在 Supabase Dashboard 的 **Authentication** > **Settings** 中配置。

- **错误处理**：当前实现包含基本的错误处理。你可以根据需要扩展错误处理逻辑。

## 已集成的功能

✅ 用户注册（邮箱 + 密码）  
✅ 用户登录（邮箱 + 密码）  
✅ 用户登出  
✅ 会话管理  
✅ 用户信息存储（昵称等）  

## 后续扩展

你可以使用 Supabase 的其他功能：

- **数据库操作**：使用 `supabase.database` 进行数据查询
- **实时订阅**：使用 `supabase.realtime` 实现实时数据同步
- **存储**：使用 `supabase.storage` 上传和管理文件
- **Edge Functions**：调用 Supabase Edge Functions

更多信息请参考 [Supabase Swift 文档](https://github.com/supabase/supabase-swift)。

