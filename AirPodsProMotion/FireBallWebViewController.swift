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

class FireBallWebViewController: JKWebViewController, CMHeadphoneMotionManagerDelegate {
    
    let handler = JKHybridHandler()
    private var referenceButton: UIButton = UIButton()
    private var motionManager = CMHeadphoneMotionManager()
    private var referenceFrame = matrix_identity_float4x4
    private var towerPoint = simd_float4(0.0, 0.0, 1.0, 0.0)
    private let mirrorTransform = simd_float4x4([
        simd_float4(-1.0, 0.0, 0.0, 0.0),
        simd_float4( 0.0, 1.0, 0.0, 0.0),
        simd_float4( 0.0, 0.0, 1.0, 0.0),
        simd_float4( 0.0, 0.0, 0.0, 1.0)
    ])
    
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
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        referenceButton.setTitle("复位", for: .normal)
        NSLayoutConstraint.activate([
            referenceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            referenceButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
        ])
        referenceButton.addTarget(self, action: #selector(referenceFrameButtonWasTapped), for: .touchUpInside)
        
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
    
    // MARK: Headphone Device Motion Handlers
    
    func headphoneMotionManager(_ motionManager: CMHeadphoneMotionManager, didUpdate deviceMotion: CMDeviceMotion) {
        
        let rotation = float4x4(rotationMatrix: deviceMotion.attitude.rotationMatrix)

        let newTower = towerPoint * mirrorTransform * rotation * referenceFrame
        let newTowerX = newTower[0]
        let degree = (Int)(asin(newTowerX) * 540 / Float.pi)
        if newTowerX < 0 {
            print("towerLeft")
            self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch(\(degree))")
        } else if newTowerX > 0 {
            print("towerRight")
            self.webView.evaluateJavaScript("window.webDispatch&&window.webDispatch(\(degree))")
        }
    }
    
    func headphoneMotionManager(_ motionManager: CMHeadphoneMotionManager, didFail error: Error) {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

