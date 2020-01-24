//
//  WebAppVC.swift
//  MysteryClient
//
//  Created by Developer on 23/01/2020.
//  Copyright © 2020 Mebius. All rights reserved.
//

import UIKit
import WebKit
class WebAppVC: MYViewController {
    class func Instance () -> WebAppVC {
        let sb = UIStoryboard(name: "WebApp", bundle: nil)
        if #available(iOS 13.0, *) {
            return sb.instantiateViewController(identifier: "WebAppVC") as! WebAppVC
        } else {
            return sb.instantiateViewController(withIdentifier: "WebAppVC") as! WebAppVC
        }
    }
    
    var page = ""
    private var webView = WKWebView()
    @IBOutlet private var container: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        container.isUserInteractionEnabled = true
        webView.navigationDelegate = self
//        if self.title?.isEmpty == false {
//            headerTitle = self.title!
//        }
        let urlPage = page.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let request = URLRequest(url: URL(string: urlPage!)!)
        webView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Loader.start()
    }
}

extension WebAppVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Loader.stop()
        alert("Errore", message: error.localizedDescription) {
            (result) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Loader.stop()
        
        webView.frame = container.bounds
        container.addSubview(webView)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(navigationResponse.response.url ?? "-")
        if let url = navigationResponse.response.url {
            if url.absoluteString.contains("logout") {
                navigationController?.popToRootViewController(animated: true)
            }
        }
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
