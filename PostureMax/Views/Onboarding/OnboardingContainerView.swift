import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var profile = OnboardingProfile()

    struct OnboardingProfile {
        var displayName = ""
        var painAreas: Set<String> = []
        var painFrequency = "sometimes"
        var sittingHours = 6
        var currentPostureRating = 5
        var goals: Set<String> = []
        var selectedPhoto: UIImage? = nil
        var selectedRoutineIds: Set<String> = []
    }

    private let totalSteps = 7

    var body: some View {
        ZStack {
            // Shared dark background for all onboarding steps
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

            switch currentStep {
            case 0:
                OnboardingSplashView { currentStep = 1 }
            case 1:
                OnboardingNameView(name: $profile.displayName) {
                    currentStep = 2
                }
            case 2:
                OnboardingQuizView(
                    painAreas: $profile.painAreas,
                    painFrequency: $profile.painFrequency,
                    sittingHours: $profile.sittingHours,
                    postureRating: $profile.currentPostureRating,
                    goals: $profile.goals
                ) {
                    currentStep = 3
                }
            case 3:
                OnboardingPhotoView(selectedImage: $profile.selectedPhoto) {
                    currentStep = 4
                }
            case 4:
                OnboardingRoutinesView(selectedIds: $profile.selectedRoutineIds) {
                    currentStep = 5
                }
            case 5:
                OnboardingLoadingView(name: profile.displayName) {
                    currentStep = 6
                }
            case 6:
                OnboardingPaywallView {
                    saveProfile()
                    coordinator.completeOnboarding()
                }
            default:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }

    private func saveProfile() {
        let userProfile = UserProfile(
            displayName: profile.displayName,
            onboardingCompleted: true,
            painAreas: Array(profile.painAreas),
            painFrequency: profile.painFrequency,
            dailySittingHours: profile.sittingHours,
            currentPostureRating: profile.currentPostureRating,
            goals: Array(profile.goals),
            selectedRoutineIds: Array(profile.selectedRoutineIds)
        )

        // Save initial photo if provided
        if let image = profile.selectedPhoto {
            if let photo = PhotoStorageService.savePhoto(image: image, category: "initial", context: modelContext) {
                userProfile.initialPhotoId = photo.id
            }
        }

        modelContext.insert(userProfile)

        // Seed default routines
        for r in RoutineDataService.defaultRoutines {
            let routine = RoutineItem(
                name: r.name,
                category: r.category,
                routineDescription: r.description,
                durationMinutes: r.duration,
                steps: r.steps,
                iconName: r.icon,
                difficulty: r.difficulty,
                targetAreas: r.targets
            )
            modelContext.insert(routine)
        }

        // Initialize streak
        let streak = StreakRecord()
        modelContext.insert(streak)

        try? modelContext.save()
    }
}
