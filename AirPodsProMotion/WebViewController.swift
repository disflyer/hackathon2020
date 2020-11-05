//
//  WebViewController.swift
//  AirPodsProMotion
//
//  Created by 方月冬 on 2020/11/5.
//

import Foundation
import JKWebViewKit
import CoreMotion

class WebViewController: JKWebViewController, CMHeadphoneMotionManagerDelegate {
    
    let handler = JKHybridHandler()
    private var motionManager = CMHeadphoneMotionManager()
    private var pitchRef = 0.0, yawRef = 0.0, rollRef = 0.0
    private let rateThreshold = 0.5
    private let gapThreshold = 0.05
    
    override init(url: URL) {
        
        handler.register()
        handler.enableHybridHandlers()
        
        super.init(url: url)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch('left')")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.delegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        if !motionManager.isDeviceMotionActive {
            weak var weakSelf = self
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (maybeDeviceMotion, maybeError) in
                if let strongSelf = weakSelf {
                    if let deviceMotion = maybeDeviceMotion {
                        strongSelf.headphoneMotionManager(strongSelf.motionManager, didUpdate:deviceMotion)
                    } else if let error = maybeError {
                        strongSelf.headphoneMotionManager(strongSelf.motionManager, didFail:error)
                    }
                }
            }
            print("Started device motion updates")
        } else {
            motionManager.stopDeviceMotionUpdates()
            print("Stop device motion updates")
        }
    }
    
    // MARK: Headphone Device Motion Handlers
    
    func headphoneMotionManager(_ motionManager: CMHeadphoneMotionManager, didUpdate deviceMotion: CMDeviceMotion) {
        
        if abs(deviceMotion.rotationRate.z) > rateThreshold {
            if deviceMotion.rotationRate.z > 0 && deviceMotion.attitude.roll - rollRef > gapThreshold {
                print("left")
                self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch('left')")
            } else if deviceMotion.rotationRate.z < 0 && rollRef - deviceMotion.attitude.roll > gapThreshold {
                print("right")
                self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch('right')")
                }
        }

    }
    
    func headphoneMotionManager(_ motionManager: CMHeadphoneMotionManager, didFail error: Error) {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

