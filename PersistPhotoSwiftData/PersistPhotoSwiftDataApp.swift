import SwiftUI
import SwiftData

@main
struct PersistPhotoSwiftDataApp: App {
    var sharedModelContainer = try! ModelContainer(for: Photo.self)

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
