import SwiftUI
import WebKit

struct ContentView: View {
    @State private var urlString = ""
    @State private var userAgent = ""
    @State private var referer = ""
    @State private var browserActive = false
    @State private var detected: [URL] = []
    @State private var playerURL: URL?
    @State private var playerHeaders: [String: String] = [:]

    @StateObject private var browser = BrowserController()

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                TextField("ألصق رابط الصفحة أو البث هنا", text: $urlString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                DisclosureGroup("ترويسات مخصصة (اختياري)") {
                    TextField("User-Agent", text: $userAgent)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    TextField("Referer", text: $referer)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Button("فتح في المتصفح") {
                        openInBrowser()
                    }
                    .buttonStyle(.borderedProminent)
                    Button("تشغيل مباشر") {
                        playDirect()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            if !detected.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("فيديو مكتشف:")
                        .font(.headline)
                    ForEach(detected, id: \.absoluteString) { url in
                        Button {
                            play(url: url)
                        } label: {
                            Label(url.lastPathComponent.isEmpty ? url.host ?? url.absoluteString : url.lastPathComponent,
                                  systemImage: "play.circle")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
            }

            if browserActive {
                HStack {
                    Button { browser.goBack() } label: { Image(systemName: "chevron.right") }
                    Button { browser.goForward() } label: { Image(systemName: "chevron.left") }
                    Button { browser.reload() } label: { Image(systemName: "arrow.clockwise") }
                    Spacer()
                    Button("إغلاق المتصفح") { browserActive = false }
                }
                .padding(.horizontal)
                BrowserView(controller: browser)
            } else {
                Spacer()
                Text("ألصق رابط صفحة، افتحها في المتصفح، ثم اختر أي فيديو يكتشفه التطبيق. أو ألصق رابط بث مباشر (.m3u8 أو .mp4 أو .mpd) وشغّله فوراً بمحرك VLC.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .sheet(item: $playerURL) { url in
            VLCPlayerView(url: url, headers: playerHeaders)
        }
        .onAppear {
            browser.onVideoFound = { url in
                if !detected.contains(url) {
                    detected.append(url)
                }
            }
        }
    }

    private func headers() -> [String: String] {
        var h: [String: String] = [:]
        if !userAgent.isEmpty { h["User-Agent"] = userAgent }
        if !referer.isEmpty { h["Referer"] = referer }
        return h
    }

    private func openInBrowser() {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespaces)),
              url.scheme == "http" || url.scheme == "https" else { return }
        detected.removeAll()
        browser.customUserAgent = userAgent.isEmpty ? nil : userAgent
        browserActive = true
        browser.load(url)
    }

    private func playDirect() {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespaces)),
              url.scheme == "http" || url.scheme == "https" else { return }
        play(url: url)
    }

    private func play(url: URL) {
        playerHeaders = headers()
        playerURL = url
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}
