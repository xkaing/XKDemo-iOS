//
//  LiveStreamView.swift
//  XKdemo
//
//  Created by wxk on 2025/11/8.
//

import SwiftUI
import AVFoundation
import Combine

// 摄像头预览视图
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.previewLayer = previewLayer
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        // 确保预览层 frame 正确设置
        if let previewLayer = uiView.previewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
    
    // 自定义 UIView 类，用于正确设置预览层
    class CameraPreviewView: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if let previewLayer = previewLayer {
                previewLayer.frame = bounds
            }
        }
    }
}

struct LiveStreamView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var captureSession: AVCaptureSession?
    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @State private var showPermissionAlert = false
    @State private var errorMessage = ""
    
    // 检测是否在模拟器上运行
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        ZStack {
            // 摄像头预览
            if isSimulator {
                // 模拟器上显示模拟的摄像头预览
                SimulatorCameraPreview()
                    .ignoresSafeArea()
            } else if cameraPermissionStatus == .authorized, let session = captureSession {
                // 真机上显示真实的摄像头预览
                CameraPreview(session: session)
                    .ignoresSafeArea()
            } else {
                // 权限未授权或摄像头未初始化
                Color.black
                    .ignoresSafeArea()
                    .overlay {
                        if cameraPermissionStatus == .denied || cameraPermissionStatus == .restricted {
                            VStack(spacing: 16) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("需要摄像头权限")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("请在设置中允许访问摄像头")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        } else if !errorMessage.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("摄像头初始化失败")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                    }
            }
            
            // 顶部信息栏
            VStack {
                HStack {
                    // 左上角：用户头像和昵称（无背景）
                    HStack(spacing: 8) {
                        // 使用默认头像图标
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        
                        // 使用 Supabase 登录后的昵称
                        Text(authManager.userNickname.isEmpty ? "用户" : authManager.userNickname)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    
                    Spacer()
                    
                    // 右上角：关闭按钮（透明背景）
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.clear)
                            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .onAppear {
            checkCameraPermission()
        }
        .onDisappear {
            stopCamera()
        }
        .alert("需要摄像头权限", isPresented: $showPermissionAlert) {
            Button("取消", role: .cancel) {
                dismiss()
            }
            Button("前往设置") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        } message: {
            Text("应用需要访问摄像头才能进行直播，请在设置中允许访问。")
        }
    }
    
    private func checkCameraPermission() {
        // 模拟器上不需要检查权限
        #if targetEnvironment(simulator)
        return
        #endif
        
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraPermissionStatus {
        case .notDetermined:
            // 请求权限
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        cameraPermissionStatus = .authorized
                        setupCamera()
                    } else {
                        cameraPermissionStatus = .denied
                        showPermissionAlert = true
                    }
                }
            }
        case .authorized:
            setupCamera()
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            errorMessage = "未知的权限状态"
        }
    }
    
    private func setupCamera() {
        // 模拟器上不需要设置摄像头
        #if targetEnvironment(simulator)
        return
        #endif
        
        // 检查权限
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            DispatchQueue.main.async {
                errorMessage = "摄像头权限未授权"
            }
            return
        }
        
        // 在后台线程配置 session
        DispatchQueue.global(qos: .userInitiated).async {
            let session = AVCaptureSession()
            session.sessionPreset = .high
            
            // 获取前置摄像头
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                DispatchQueue.main.async {
                    errorMessage = "无法访问前置摄像头"
                }
                return
            }
            
            // 创建输入
            var input: AVCaptureDeviceInput
            do {
                input = try AVCaptureDeviceInput(device: frontCamera)
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "无法创建摄像头输入: \(error.localizedDescription)"
                }
                return
            }
            
            // 配置 session
            session.beginConfiguration()
            
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                session.commitConfiguration()
                DispatchQueue.main.async {
                    errorMessage = "无法添加摄像头输入"
                }
                return
            }
            
            // 不需要输出，只需要预览
            session.commitConfiguration()
            
            // 启动 session
            session.startRunning()
            
            // 在主线程更新 UI
            DispatchQueue.main.async {
                captureSession = session
                errorMessage = ""
            }
        }
    }
    
    private func stopCamera() {
        captureSession?.stopRunning()
        captureSession = nil
    }
}

// 模拟器摄像头预览（占位视图）
struct SimulatorCameraPreview: View {
    var body: some View {
        ZStack {
            // 渐变背景，模拟摄像头画面
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.15, blue: 0.3),
                    Color(red: 0.15, green: 0.2, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 模拟摄像头画面效果
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.6))
                        Text("模拟器模式")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text("请在真机上测试摄像头功能")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                    )
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// 模糊效果视图
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

#Preview {
    LiveStreamView()
        .environmentObject(AuthManager())
}

