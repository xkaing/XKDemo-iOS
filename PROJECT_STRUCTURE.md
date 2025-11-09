# 项目结构优化建议

本文档说明如何优化项目结构，提高代码的可维护性和可读性。

## 📁 当前结构

当前所有 Swift 文件都在 `XKdemo/` 根目录下，虽然功能完整，但随着项目增长，建议按功能模块组织代码。

## 🎯 推荐结构

### 方案一：按功能模块分组（推荐）

```
XKdemo/
├── App/
│   └── XKdemoApp.swift          # 应用入口
│
├── Views/                        # 视图层
│   ├── Content/
│   │   └── ContentView.swift    # 主视图（TabView）
│   ├── Home/
│   │   └── HomeView.swift       # 主页视图
│   ├── Community/
│   │   ├── CommunityView.swift  # 社区视图
│   │   └── ComposePostView.swift # 发布动态视图
│   ├── Live/
│   │   └── LiveStreamView.swift # 直播视图
│   ├── Profile/
│   │   └── ProfileView.swift    # 个人中心视图
│   └── Auth/
│       ├── LoginView.swift     # 登录视图
│       └── RegisterView.swift  # 注册视图
│
├── Components/                   # 可复用组件
│   ├── FeatureCard.swift        # 功能卡片组件
│   └── PostCard.swift           # 动态卡片组件
│
├── Models/                       # 数据模型
│   ├── Post.swift               # 动态数据模型
│   ├── Moment.swift             # Moment 数据模型
│   └── Profile.swift            # 用户资料模型
│
├── Services/                     # 服务层
│   ├── Auth/
│   │   └── AuthManager.swift    # 认证管理器
│   ├── Profile/
│   │   └── ProfileService.swift # 用户资料服务
│   ├── Moments/
│   │   └── MomentsService.swift # 动态服务
│   └── Storage/
│       └── StorageService.swift # 存储服务
│
├── Managers/                     # 管理器
│   ├── SupabaseManager.swift    # Supabase 客户端管理
│   └── SupabaseConfig.swift     # Supabase 配置常量
│
└── Assets.xcassets/              # 资源文件
```

### 方案二：按层级分组（简单）

```
XKdemo/
├── App/
│   └── XKdemoApp.swift
│
├── Views/                        # 所有视图
│   ├── ContentView.swift
│   ├── HomeView.swift
│   ├── CommunityView.swift
│   ├── ComposePostView.swift
│   ├── LiveStreamView.swift
│   ├── ProfileView.swift
│   ├── LoginView.swift
│   └── RegisterView.swift
│
├── Components/                   # 所有组件
│   ├── FeatureCard.swift
│   └── PostCard.swift
│
├── Models/                       # 所有模型
│   ├── Post.swift
│   ├── Moment.swift
│   └── Profile.swift
│
├── Services/                     # 所有服务
│   ├── AuthManager.swift
│   ├── ProfileService.swift
│   ├── MomentsService.swift
│   └── StorageService.swift
│
├── Managers/                     # 所有管理器
│   ├── SupabaseManager.swift
│   └── SupabaseConfig.swift
│
└── Assets.xcassets/
```

## 🔄 迁移步骤

### 在 Xcode 中重组文件

1. **创建文件夹结构**

   - 在 Xcode 中右键点击 `XKdemo` 文件夹
   - 选择 **New Group** 创建新组
   - 创建以下组：`Views`、`Components`、`Models`、`Services`、`Managers`

2. **移动文件**

   - 将文件拖拽到对应的组中
   - Xcode 会自动更新文件引用

3. **更新导入语句**（如果需要）
   - 检查是否有相对导入路径
   - Swift 通常不需要修改导入语句

### 注意事项

- ✅ Xcode 中的 Group 是逻辑分组，不会改变文件系统结构
- ✅ 如果需要在文件系统中也创建文件夹，可以在 Finder 中手动创建，然后在 Xcode 中拖拽文件
- ✅ 建议先在 Xcode 中创建 Group，这样更安全

## 📝 文件命名规范

### 视图文件

- 以 `View` 结尾：`HomeView.swift`、`ProfileView.swift`
- 使用 PascalCase：`ComposePostView.swift`

### 服务文件

- 以 `Service` 或 `Manager` 结尾：`AuthManager.swift`、`ProfileService.swift`
- 使用 PascalCase：`MomentsService.swift`

### 模型文件

- 使用单数形式：`Post.swift`、`Profile.swift`
- 使用 PascalCase

### 组件文件

- 以组件类型结尾：`FeatureCard.swift`、`PostCard.swift`
- 使用 PascalCase

## 🎨 代码组织最佳实践

### 1. 单一职责原则

每个文件应该只负责一个功能或一个概念。

### 2. 依赖方向

- Views → Services → Managers
- 避免循环依赖

### 3. 配置集中管理

所有配置常量集中在 `SupabaseConfig.swift` 中。

### 4. 服务层抽象

使用协议（Protocol）定义服务接口，便于测试和替换。

## 🔍 当前项目文件分类

### Views（视图）

- `ContentView.swift`
- `HomeView.swift`
- `CommunityView.swift`
- `ComposePostView.swift`
- `LiveStreamView.swift`
- `ProfileView.swift`
- `LoginView.swift`
- `RegisterView.swift`

### Components（组件）

- `FeatureCard.swift`
- `PostCard.swift`

### Models（模型）

- `Post.swift`
- `Moment.swift`（在 `MomentsService.swift` 中）
- `Profile.swift`（在 `ProfileService.swift` 中）

### Services（服务）

- `AuthManager.swift`
- `ProfileService.swift`
- `MomentsService.swift`
- `StorageService.swift`

### Managers（管理器）

- `SupabaseManager.swift`
- `SupabaseConfig.swift`

### App（应用入口）

- `XKdemoApp.swift`

## 📚 参考资源

- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [SwiftUI Best Practices](https://developer.apple.com/documentation/swiftui)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
