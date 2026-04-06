import SwiftUI
import SwiftData

@main
struct PostureMaxApp: App {
    @State private var appCoordinator = AppCoordinator()
    @State private var showSplash = true

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            DailyLog.self,
            PosturePhoto.self,
            RoutineItem.self,
            StreakRecord.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        PurchaseManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environment(appCoordinator)
                    .modelContainer(sharedModelContainer)
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    AnimatedSplashScreen {
                        withAnimation(.easeOut(duration: 0.4)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                }
            }
            .task {
                await PurchaseManager.shared.checkProStatus()
            }
        }
    }
}

// MARK: - Animated Splash Screen
struct AnimatedSplashScreen: View {
    let onFinished: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: CGFloat = 0
    @State private var textOpacity: CGFloat = 0
    @State private var glowOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            // Full-bleed splash background image
            Image(colorScheme == .dark ? "Splash-Dark" : "Splash-Light")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Overlay content
            VStack(spacing: 20) {
                Spacer()

                // Brand icon with glow
                ZStack {
                    // Teal glow behind icon
                    Circle()
                        .fill(Color.pmPrimary.opacity(0.25))
                        .frame(width: 160, height: 160)
                        .blur(radius: 30)
                        .opacity(glowOpacity)

                    Image("BrandIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: Color.pmPrimary.opacity(0.4), radius: 20)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                VStack(spacing: 6) {
                    Text("PostureMax")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.pmGradient)

                    Text("Stand Taller Every Day")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .task {
            // Staggered entrance animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            try? await Task.sleep(for: .seconds(0.3))

            withAnimation(.easeOut(duration: 0.5)) {
                glowOpacity = 1.0
                textOpacity = 1.0
            }
            try? await Task.sleep(for: .seconds(1.2))

            onFinished()
        }
    }
}
