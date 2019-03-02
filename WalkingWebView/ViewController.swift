//
//  ViewController.swift
//  WalkingWebView
//
//  Created by 齋藤健悟 on 2019/03/02.
//  Copyright © 2019 齋藤健悟. All rights reserved.
//

import UIKit
import ARKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var sceneView: ARSCNView!
    
    override func loadView() {
        super.loadView()
        
        sceneView = ARSCNView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        view.addSubview(sceneView)
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view.addSubview(webView)
        
        webView.alpha = 0.9
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://www.google.co.jp")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let frame = UIScreen.main.bounds
        let marginRate = CGFloat(0.1)
        let webViewFrame = CGRect(x: frame.width * marginRate / 2,
                                  y: frame.height * marginRate,
                                  width: frame.width * (1 - marginRate),
                                  height: frame.height * (1 - marginRate))
        webView.frame = webViewFrame
        sceneView.frame = frame
    }
}
