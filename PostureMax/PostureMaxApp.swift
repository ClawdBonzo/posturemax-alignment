import SwiftUI
import SwiftData

@main
struct PostureMaxApp: App {
    @State private var appCoordinator = AppCoordinator()

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

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appCoordinator)
                .modelContainer(sharedModelContainer)
        }
    }
}
