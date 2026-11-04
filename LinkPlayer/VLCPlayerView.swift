import SwiftUI
import VLCKit

// Full-screen player based on VLC (MobileVLCKit).
// Plays HLS (.m3u8), progressive (.mp4/.mov), MPEG-DASH (.mpd) and the
// other formats libVLC supports — everything AVPlayer cannot play,
// except Widevine DRM, which no iOS engine can play at all.
// Custom headers are passed as libVLC media options, the same mechanism
// Android players use (for example ":http-user-agent=").

final class VLCPlayerModel: ObservableObject {
    let player = VLCMediaPlayer()

    init(url: URL, headers: [String: String]) {
        let media = VLCMedia(url: url)
        if let ua = headers["User-Agent"], !ua.isEmpty {
            media.addOption("http-user-agent=\(ua)")
        }
        if let ref = headers["Referer"], !ref.isEmpty {
            media.addOption("http-referrer=\(ref)")
        }
        player.media = media
    }

    func play() { player.play() }
    func stop() { player.stop() }
}

private struct VLCVideoView: UIViewRepresentable {
    @ObservedObject var model: VLCPlayerModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        model.player.drawable = view
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct VLCPlayerView: View {
    let url: URL
    let headers: [String: String]

    @StateObject private var model: VLCPlayerModel

    init(url: URL, headers: [String: String]) {
        self.url = url
        self.headers = headers
        _model = StateObject(wrappedValue: VLCPlayerModel(url: url, headers: headers))
    }

    var body: some View {
        ZStack {
            VLCVideoView(model: model)
                .ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("إيقاف") {
                        model.stop()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            }
        }
        .onAppear { model.play() }
        .onDisappear { model.stop() }
    }
}
