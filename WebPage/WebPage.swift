//
//  WebPage
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import WebKit

class WebPage: MYViewController {
    enum WebPageEnum: String {
        case recover = "login/retrieve-password/app/1"
        case register = "login/register?app=1"
        
        case profile = "mystery/profile"
        case chat = "ticket/chat"
        case storico = "checking/executed"
        case find = "checking/finder"
        case cercando = "mystery/communications"
        case news = "mystery/news"
        case contattaci = "ticket"
        case learning = "learning"
        
        case bookingRemove = "checking/booking-remove?id="
        case bookingMove = "checking/booking-move?id="
        case ticketView = "checking/ticket-view?id="
        case none = ""
    }
    
    class func Instance (type: WebPageEnum, id: Int = 0) -> WebPage {
        let vc = Instance(sbName: "WebPage", isInitial: true) as! WebPage
        if type != .none {
            var page = Config.Url.home + type.rawValue
            if id > 0 {
                page += String(id)
            }
            vc.page = page
        }
        if type == .register {
            vc.isSignUp = true;
        }
        return vc
    }
    
    private var webView = WKWebView()
    @IBOutlet private var container: UIImageView!

    var isSignUp = false;
    var page = ""    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.isUserInteractionEnabled = true
        webView.navigationDelegate = self
        if self.title?.isEmpty == false {
            headerTitle = self.title!
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if page.isEmpty {
            return
        }
        MYHud.show()

        if isSignUp {
            let urlPage = page.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let request = URLRequest(url: URL(string: urlPage!)!)
            webView.load(request)
            return
        }
        
        func hasToken () {
            let urlPage = page.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            var request = URLRequest(url: URL(string: urlPage!)!)
            request.setValue(User.shared.token, forHTTPHeaderField: "Authorization")
            webView.load(request)
        }
        User.shared.getUserToken(completion: { (redirect_url) in
            hasToken()
        }) { (errorCode, message) in
            self.alert(errorCode, message: message) {
                (result) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension WebPage: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        MYHud.hide()
        alert("Errore", message: error.localizedDescription) {
            (result) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MYHud.hide()
        webView.frame = container.bounds
        container.addSubview(webView)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(navigationResponse.response)
        decisionHandler(.allow)
    }
    
    private func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return nil
    }
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print(challenge)
//        completionHandler(.useCredential, nil)
//    }
}
