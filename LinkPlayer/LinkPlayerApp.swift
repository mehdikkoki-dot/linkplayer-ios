import SwiftUI

// Original app, v2: same features as v1, but the playback engine is VLC
// (MobileVLCKit) instead of AVPlayer, so it also plays MPEG-DASH and the
// other formats AVPlayer cannot play. Widevine DRM remains impossible on
// iOS regardless of engine — that is a platform limit, not an app limit.

@main
struct LinkPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
