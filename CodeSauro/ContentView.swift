import SwiftUI
import WebKit

class WebviewScrollViewDelegate: NSObject, UIScrollViewDelegate {

    var webview: WKWebView?

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let webview = webview {
            scrollView.bounds = webview.bounds
            scrollView.zoomScale = webview.pageZoom
        }
    }
}

struct ContentView: View {
    private let urlString: String = "http://localhost:4200/"
    
    var body: some View {
        WebView(url: URL(string: urlString)!)
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebView: UIViewRepresentable {
    var url: URL
    let webviewScrollViewDelegate = WebviewScrollViewDelegate()
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.delegate = webviewScrollViewDelegate
        webviewScrollViewDelegate.webview = webView
        
        let source = """
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                var head = document.getElementsByTagName('head')[0];
                head.appendChild(meta);
                """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

#Preview {
    ContentView()
}
