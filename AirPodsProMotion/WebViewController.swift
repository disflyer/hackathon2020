//
//  WebViewController.swift
//  AirPodsProMotion
//
//  Created by 方月冬 on 2020/11/5.
//

import Foundation
import JKWebViewKit

class WebViewController: JKWebViewController {
    let handler = JKHybridHandler()
    let text = "test"
    override init(url: URL) {
        
        handler.register()
        handler.enableHybridHandlers()
        
        super.init(url: url)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            self.webView.evaluateJavaScript("window.console.error('test');window.webDispatch&&window.webDispatch()")
        }
        
     
    }
    
    func testtest() -> String {
        print("testestestest")
        return text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

