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
            StreakRecord.self,
            GamificationProfile.self,
            Quest.self,
            Badge.self
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
            // Dark background — consistent with onboarding
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.14),
                    Color(red: 0.02, green: 0.04, blue: 0.10),
                    Color(red: 0.04, green: 0.08, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(Color.pmPrimary.opacity(0.18))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(y: -40)
                .opacity(glowOpacity)

            // Content
            VStack(spacing: 20) {
                Spacer()

                // Brand icon with glow
                ZStack {
                    Circle()
                        .fill(Color.pmPrimary.opacity(0.3))
                        .frame(width: 180, height: 180)
                        .blur(radius: 35)
                        .opacity(glowOpacity)

                    Image("BrandIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: Color.pmPrimary.opacity(0.6), radius: 24)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                VStack(spacing: 6) {
                    Text("PostureMax")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pmPrimary, .pmGold, .pmCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .neonGlow(radius: 10)

                    Text("Stand Taller Every Day")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.55))
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
