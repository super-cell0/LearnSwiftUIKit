//
//  WebViewController.swift
//  MarkupAssistant
//
//  Created by lin on 2020/5/14.
//  Copyright © 2020 SmartItFarmer. All rights reserved.
//

import UIKit
import WebKit

open class PodWebViewController: UIViewController, StoryboardLoadable {
    @IBOutlet weak open var vWebHolder: UIView!
    var webView: WKWebView!
    
    // MARK: - Variables
    public var url: String = H.t("setting.privacy_url")
    public var webTitle: String = H.t("setting.privacy_title")

    open func storyboardName() -> String {
        return "Setting"
    }
    
    open func identifier() -> String {
        return "PodWebViewController"
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.webTitle
        guard let url = URL(string: self.url) else { return }
        let request = URLRequest(url: url)
        let script = """
                        var style = document.createElement('style');
                        style.innerHTML = '.sgui-header.fixed { display: none; } .cube-z-bottom-bar.button-bottom-bar.bottom-bar { display: none; } .red-block { display: none; }';
                        document.head.appendChild(style);
                     """
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController

        webView = WKWebView(frame: self.view.bounds, configuration: webViewConfiguration)
        webView?.load(request)
        self.view.addSubview(webView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    open override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //vWebview.frame = vWebHolder.frame
    }

    @IBAction func back() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PodWebViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
