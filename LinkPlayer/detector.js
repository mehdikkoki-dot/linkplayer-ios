// Injected into every page the user opens in the built-in browser.
// Reports playable media URLs (video tags, fetch/XHR media requests)
// back to the app through the "videoDetector" message handler.
// Generic only: no site names, no URL patterns for any specific site.
// v2: DASH manifests (.mpd) added alongside HLS and progressive files.

(function () {
    function isMedia(u) {
        return !!u && /\.(m3u8|mp4|mov|mpd)(\?|#|$)/i.test(u);
    }
    function report(u) {
        try {
            if (isMedia(u) && window.webkit && window.webkit.messageHandlers.videoDetector) {
                window.webkit.messageHandlers.videoDetector.postMessage(u);
            }
        } catch (e) {}
    }
    function scan() {
        document.querySelectorAll("video").forEach(function (v) {
            report(v.currentSrc || v.src);
            v.querySelectorAll("source").forEach(function (s) { report(s.src); });
        });
    }
    var ofetch = window.fetch;
    window.fetch = function () {
        var a = arguments[0];
        report(typeof a === "string" ? a : (a && a.url));
        return ofetch.apply(this, arguments);
    };
    var oopen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function (m, u) {
        report(u);
        return oopen.apply(this, arguments);
    };
    document.addEventListener("DOMContentLoaded", scan);
    window.addEventListener("load", scan);
    if (document.documentElement) {
        new MutationObserver(scan).observe(document.documentElement, { childList: true, subtree: true });
    }
    setTimeout(scan, 2000);
})();
