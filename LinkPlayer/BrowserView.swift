import SwiftUI
import WebKit

// Generic video-detecting browser (v2: DASH manifests added).
// It watches for navigations to media files and for <video> / network media
// URLs reported by the injected script, then hands them to the player.
// It contains no site-specific logic: it works on any page the user opens.

final class BrowserController: ObservableObject {
    var onVideoFound: ((URL) -> Void)?
    var customUserAgent: String?

    private(set) var webView: WKWebView!

    init() {
        let config = WKWebViewConfiguration()
        config.userContentController.add(Handler(parent: self), name: "videoDetector")
        if let scriptPath = Bundle.main.path(forResource: "detector", ofType: "js"),
           let source = try? String(contentsOfFile: scriptPath, encoding: .utf8) {
            let script = WKUserScript(source: source,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: false)
            config.userContentController.addUserScript(script)
        }
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = Handler(parent: self)
        webView.uiDelegate = Handler(parent: self)
    }

    func load(_ url: URL) {
        if let ua = customUserAgent, !ua.isEmpty {
            webView.customUserAgent = ua
        }
        webView.load(URLRequest(url: url))
    }

    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func reload() { webView.reload() }

    fileprivate func found(_ url: URL) {
        onVideoFound?(url)
    }

    // One handler object serves as navigation delegate, UI delegate,
    // and script-message handler.
    private final class Handler: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        weak var parent: BrowserController?

        init(parent: BrowserController) {
            self.parent = parent
        }

        // A navigation that IS a media file -> play it instead of loading it.
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationResponse: WKNavigationResponse,
                     decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            let response = navigationResponse.response
            let mime = response.mimeType ?? ""
            let ext = response.url?.pathExtension.lowercased() ?? ""
            let isMedia = mime.hasPrefix("video/")
                || mime == "application/vnd.apple.mpegurl"
                || mime == "application/x-mpegURL"
                || mime == "application/dash+xml"
                || ext == "m3u8" || ext == "mp4" || ext == "mov" || ext == "mpd"
            if isMedia, let url = response.url {
                parent?.found(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        // Links that open a new window/tab -> open in the same web view.
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "videoDetector",
                  let text = message.body as? String,
                  let url = URL(string: text) else { return }
            parent?.found(url)
        }
    }
}

struct BrowserView: UIViewRepresentable {
    let controller: BrowserController

    func makeUIView(context: Context) -> WKWebView {
        controller.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
