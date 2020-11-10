//
//  WebViewController.swift
//  AirPodsProMotion
//
//  Created by 方月冬 on 2020/11/5.
//

import Foundation
import JKWebViewKit
import CoreMotion
import simd

class WebViewController: JKWebViewController, CMHeadphoneMotionManagerDelegate {
    
    let handler = JKHybridHandler()
    private var referenceButton: UIButton = UIButton()
    private var backButton: UIButton = UIButton()
    private var motionManager = CMHeadphoneMotionManager()
    private var referenceFrame = matrix_identity_float4x4
    private var headPoint = simd_float4(0.0, 1.0, 0.0, 0.0)
    private let mirrorTransform = simd_float4x4([
        simd_float4(-1.0, 0.0, 0.0, 0.0),
        simd_float4( 0.0, 1.0, 0.0, 0.0),
        simd_float4( 0.0, 0.0, 1.0, 0.0),
        simd_float4( 0.0, 0.0, 0.0, 1.0)
    ])
    private var upCnt = 0;
    
    override init(url: URL) {
        
        handler.register()
        handler.enableHybridHandlers()
        
        super.init(url: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.delegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.view.addSubview(referenceButton)
        self.view.bringSubviewToFront(referenceButton)
        self.view.addSubview(backButton)
        self.view.bringSubviewToFront(backButton)
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        referenceButton.setTitle("复位", for: .normal)
        NSLayoutConstraint.activate([
            referenceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            referenceButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
        ])
        referenceButton.addTarget(self, action: #selector(referenceFrameButtonWasTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("返回", for: .normal)
        NSLayoutConstraint.activate([
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
        ])
        backButton.addTarget(self, action: #selector(backFrameButtonWasTapped), for: .touchUpInside)
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
    
    @IBAction func referenceFrameButtonWasTapped(_ sender: UIButton)
    {
        if let deviceMotion = motionManager.deviceMotion {
            referenceFrame = float4x4(rotationMatrix: deviceMotion.attitude.rotationMatrix).inverse
        }
    }
    
    @IBAction func backFrameButtonWasTapped(_ sender: UIButton)
    {
        self.navigationController?.pushViewController(HomeViewController(), animated: true)
    }
    // MARK: Headphone Device Motion Handlers
    
    func headphoneMotionManager(_ motionManager: CMHeadphoneMotionManager, didUpdate deviceMotion: CMDeviceMotion) {
        
        let rotation = float4x4(rotationMatrix: deviceMotion.attitude.rotationMatrix)

        let newHead = headPoint * mirrorTransform * rotation * referenceFrame
        
        let newX = newHead[0]
        let percent = min((Int)(abs(asin(newX)) * 1400 / Float.pi), 100)
        if newX > 0 {
            print("'left', \(percent)")
            self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch('left', \(percent))")
        } else if newX < 0 {
            print("'right', \(percent)")
            self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch('right', \(percent))")
        }
        
        let newZ = newHead[2]
        if newZ > 0 {
            print("up")
            upCnt += 1
            if upCnt % 4 == 0 {
                self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch('top')")
            }
        } else if newZ < 0 {
            print("down")
            upCnt = 0
            self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch('bottom')")
        }
    }
    
    func headphoneMotionManager(_ motionManager: CMHeadphoneMotionManager, didFail error: Error) {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

