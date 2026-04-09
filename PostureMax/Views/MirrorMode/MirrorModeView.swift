import SwiftUI
import AVFoundation

// MARK: - Camera Manager

@Observable
final class MirrorCameraManager: @unchecked Sendable {
    var isReady       = false
    var isAuthorized  = false
    let session       = AVCaptureSession()

    func setup() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            isAuthorized = true
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted { self.startSession() }
                }
            }
        default:
            isAuthorized = false
        }
    }

    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                let input  = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)
            self.session.commitConfiguration()
            self.session.startRunning()

            DispatchQueue.main.async {
                self.isReady = true
            }
        }
    }

    func stop() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraUIView {
        let view = CameraUIView()
        view.previewLayer.session       = session
        view.previewLayer.videoGravity  = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraUIView, context: Context) {}

    class CameraUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

// MARK: - Mirror Mode View

struct MirrorModeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var camera         = MirrorCameraManager()
    @State private var postureState   = PostureState.checking
    @State private var sparklePhase   = false
    @State private var gridOpacity    = 0.0
    @State private var showGuides     = true
    @State private var checkPulse     = false

    enum PostureState {
        case checking, good, perfect
        var label: String {
            switch self {
            case .checking: return "Align yourself with the grid"
            case .good:     return "Almost there — open your shoulders"
            case .perfect:  return "PERFECT ALIGNMENT"
            }
        }
        var color: Color {
            switch self {
            case .checking: return .pmCyan
            case .good:     return .pmGold
            case .perfect:  return .pmPrimary
            }
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if camera.isAuthorized {
                // Camera feed
                CameraPreviewView(session: camera.session)
                    .ignoresSafeArea()
                    .opacity(camera.isReady ? 1 : 0)
                    .animation(.easeIn(duration: 0.4), value: camera.isReady)

                // Golden alignment grid
                AlignmentGridOverlay(opacity: gridOpacity, sparkle: postureState == .perfect && sparklePhase)

                // Body guide lines
                if showGuides {
                    BodyGuideOverlay()
                }

                // Posture feedback banner
                VStack {
                    Spacer()

                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(postureState.color)
                                .frame(width: 8, height: 8)
                                .neonGlow(color: postureState.color, radius: 6)
                                .scaleEffect(checkPulse ? 1.4 : 1.0)

                            Text(postureState.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial.opacity(0.7))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(postureState.color.opacity(0.6), lineWidth: 1.5)
                        )
                        .neonGlow(color: postureState.color, radius: 8)

                        // Posture check button
                        Button {
                            checkPosture()
                        } label: {
                            Text("Check My Alignment")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.pmPrimary, .pmGold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .neonGlow(radius: 10)
                        }
                    }
                    .padding(.bottom, 60)
                }
            } else {
                // No permission state
                VStack(spacing: 20) {
                    Image(systemName: "camera.slash.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.pmPrimary)

                    Text("Camera Access Required")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Enable camera access in Settings to use Mirror Mode")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundStyle(Color.pmPrimary)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        camera.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white.opacity(0.8))
                            .shadow(radius: 4)
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                Spacer()
            }

            // Guides toggle
            VStack {
                HStack {
                    Button {
                        withAnimation { showGuides.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: showGuides ? "eye.slash.fill" : "eye.fill")
                                .font(.caption)
                            Text(showGuides ? "Hide guides" : "Show guides")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial.opacity(0.5))
                        .clipShape(Capsule())
                    }
                    .padding(.top, 68)
                    .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            camera.setup()
            withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
                gridOpacity = 1
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                checkPulse = true
            }
        }
        .onDisappear {
            camera.stop()
        }
    }

    private func checkPosture() {
        // Cycle through states for demonstration — in production, wire to Vision/ML
        withAnimation(.spring(response: 0.4)) {
            switch postureState {
            case .checking: postureState = .good
            case .good:     postureState = .perfect
            case .perfect:  postureState = .checking
            }
        }

        if postureState == .perfect {
            withAnimation(.easeInOut(duration: 0.4).repeatCount(6, autoreverses: true)) {
                sparklePhase.toggle()
            }
            HapticService.shared.playQuestCompletionHaptic()
        }
    }
}

// MARK: - Alignment Grid Overlay

private struct AlignmentGridOverlay: View {
    let opacity:  Double
    let sparkle:  Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Vertical thirds
                ForEach([1, 2], id: \.self) { i in
                    Rectangle()
                        .fill(Color.pmGold.opacity(sparkle ? 0.7 : 0.35))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .position(x: geo.size.width * CGFloat(i) / 3, y: geo.size.height / 2)
                        .neonGlow(color: .pmGold, radius: sparkle ? 12 : 4)
                }

                // Horizontal thirds
                ForEach([1, 2], id: \.self) { i in
                    Rectangle()
                        .fill(Color.pmGold.opacity(sparkle ? 0.7 : 0.35))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .position(x: geo.size.width / 2, y: geo.size.height * CGFloat(i) / 3)
                        .neonGlow(color: .pmGold, radius: sparkle ? 12 : 4)
                }

                // Center crosshair
                ZStack {
                    Rectangle().fill(Color.pmPrimary.opacity(0.6)).frame(width: 20, height: 1.5)
                    Rectangle().fill(Color.pmPrimary.opacity(0.6)).frame(width: 1.5, height: 20)
                }
                .neonGlow(radius: 6)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // Corner sparkles when perfect
                if sparkle {
                    ForEach([(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)], id: \.0) { cx, cy in
                        Image(systemName: "sparkle")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.pmGold)
                            .goldGlow(radius: 12)
                            .position(
                                x: geo.size.width  * cx + (cx == 0 ? 24 : -24),
                                y: geo.size.height * cy + (cy == 0 ? 80 : -24)
                            )
                    }
                }
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
    }
}

// MARK: - Body Guide Overlay

private struct BodyGuideOverlay: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Shoulder line
                Rectangle()
                    .fill(Color.pmCyan.opacity(0.45))
                    .frame(width: geo.size.width * 0.6, height: 1.5)
                    .blur(radius: 1)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.35)
                    .neonGlow(color: .pmCyan, radius: 6)

                // Hip line
                Rectangle()
                    .fill(Color.pmCyan.opacity(0.45))
                    .frame(width: geo.size.width * 0.5, height: 1.5)
                    .blur(radius: 1)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.62)
                    .neonGlow(color: .pmCyan, radius: 6)

                // Spine center line
                Rectangle()
                    .fill(Color.pmPrimary.opacity(0.3))
                    .frame(width: 1.5, height: geo.size.height * 0.35)
                    .blur(radius: 1)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.48)
                    .neonGlow(color: .pmPrimary, radius: 5)

                // Labels
                VStack(spacing: 0) {
                    Spacer().frame(height: geo.size.height * 0.35 - 18)
                    Text("SHOULDERS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.pmCyan.opacity(0.8))
                        .padding(.leading, geo.size.width * 0.72)
                }

                VStack(spacing: 0) {
                    Spacer().frame(height: geo.size.height * 0.62 - 18)
                    Text("HIPS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.pmCyan.opacity(0.8))
                        .padding(.leading, geo.size.width * 0.72)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
