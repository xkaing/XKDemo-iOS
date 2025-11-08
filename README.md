# XKdemo iOS

一个使用 SwiftUI 开发的 iOS 社交应用演示项目，包含直播、动态发布等核心功能。

## 📱 功能特性

### 主页
- **功能卡片展示**：采用 App Store 风格的卡片设计
- **开直播**：点击卡片可打开前置摄像头进行直播
- **发动态**：快速跳转到社区页面并打开发布动态界面
- **待开发**：预留功能入口

### 社区
- **动态列表**：浏览用户发布的动态
- **发布动态**：支持文字和图片内容
- **用户信息**：显示发布者头像、昵称和发布时间

### 直播功能
- **前置摄像头**：实时显示前置摄像头画面
- **用户信息显示**：左上角显示当前用户头像和昵称
- **权限管理**：自动请求摄像头权限，友好的权限提示

### 个人中心
- **用户信息**：显示用户头像和昵称

## 🛠 技术栈

- **开发语言**：Swift
- **UI 框架**：SwiftUI
- **最低支持版本**：iOS 18.6
- **开发工具**：Xcode 26.1+

## 📋 项目结构

```
XKdemo/
├── XKdemoApp.swift          # 应用入口
├── ContentView.swift         # 主视图（TabView）
├── HomeView.swift            # 主页视图
├── CommunityView.swift       # 社区视图
├── ComposePostView.swift     # 发布动态视图
├── LiveStreamView.swift      # 直播视图
├── ProfileView.swift         # 个人中心视图
├── FeatureCard.swift         # 功能卡片组件
├── PostCard.swift            # 动态卡片组件
├── Post.swift                # 动态数据模型
├── User.swift                # 用户数据模型
└── Assets.xcassets/          # 资源文件
```

## 🚀 快速开始

### 环境要求

- macOS 14.0+
- Xcode 26.1+
- iOS 18.6+ 设备或模拟器

### 安装步骤

1. 克隆项目
```bash
git clone https://github.com/yourusername/XKDemo-iOS.git
cd XKDemo-iOS
```

2. 打开项目
```bash
open XKdemo.xcodeproj
```

3. 配置开发团队
   - 在 Xcode 中选择项目
   - 在 Signing & Capabilities 中设置你的开发团队

4. 运行项目
   - 选择目标设备（真机或模拟器）
   - 按 `Cmd + R` 运行

### 权限配置

应用需要以下权限：

- **摄像头权限**：用于直播功能
  - 已在 `Info.plist` 中配置 `NSCameraUsageDescription`
  - 首次使用时会自动请求权限

## 📸 功能截图

### 主页
主页展示功能卡片，采用渐变色背景，支持点击跳转。

### 社区
社区页面显示动态列表，支持发布文字和图片动态。

### 直播
直播页面使用前置摄像头，实时显示画面，支持权限管理。

## 🎨 UI 设计

- **卡片设计**：采用 App Store 风格的卡片，支持自定义渐变色
- **现代化界面**：使用 SwiftUI 原生组件，支持深色模式
- **流畅动画**：页面切换和交互使用系统动画

## 🔧 开发说明

### 添加新功能卡片

在 `HomeView.swift` 中的 `cardConfigs` 数组中添加新的 `CardConfig`：

```swift
CardConfig(
    title: "新功能",
    description: "功能描述",
    gradientColors: [
        Color(red: 0.5, green: 0.2, blue: 0.9),
        // 更多颜色...
    ],
    action: {
        // 点击事件
    }
)
```

### 自定义卡片样式

修改 `FeatureCard.swift` 中的样式定义。

## 📝 注意事项

1. **摄像头权限**：真机测试时需要授予摄像头权限
2. **模拟器限制**：模拟器不支持真实摄像头，会显示占位视图
3. **网络图片**：动态中的图片使用随机图片服务（picsum.photos）

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目仅供学习和演示使用。

## 👤 作者

Created by wxk

---

**注意**：这是一个演示项目，部分功能（如直播推流）尚未完全实现。

