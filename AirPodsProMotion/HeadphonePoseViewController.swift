
import UIKit
import SceneKit
import CoreMotion
import simd

extension float4x4 {
    init(rotationMatrix r: CMRotationMatrix) {
        self.init([
            simd_float4(Float(-r.m11), Float(r.m13), Float(r.m12), 0.0),
            simd_float4(Float(-r.m31), Float(r.m33), Float(r.m32), 0.0),
            simd_float4(Float(-r.m21), Float(r.m23), Float(r.m22), 0.0),
            simd_float4(          0.0,          0.0,          0.0, 1.0)
        ])
    }
}

class HeadphonePoseViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    
    var sceneView: SCNView = SCNView()
    var motionButton: UIButton = UIButton()
    var referenceButton: UIButton = UIButton()
    var label: UILabel = UILabel()
    var left: UILabel = UILabel()
    var right: UILabel = UILabel()
    
    private var motionManager = CMHeadphoneMotionManager()
    private var headNode: SCNNode?
    private var referenceFrame = matrix_identity_float4x4
    private var pitchRef = 0.0, yawRef = 0.0, rollRef = 0.0
    private let rateThreshold = 0.5
    private let gapThreshold = 0.05

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.darkGray
        self.view.addSubview(sceneView)
        self.view.addSubview(motionButton)
        self.view.addSubview(referenceButton)
        self.view.addSubview(label)
        self.view.addSubview(left)
        self.view.addSubview(right)
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        motionButton.translatesAutoresizingMaskIntoConstraints = false
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        left.translatesAutoresizingMaskIntoConstraints = false
        right.translatesAutoresizingMaskIntoConstraints = false
        
        
        motionButton.setTitle("开始追踪", for: .normal)
        referenceButton.setTitle("复位重置", for: .normal)
        label.text = "当前方向"
        left.text = "左"
        left.font = left.font.withSize(40)
        right.text = "右"
        right.font = right.font.withSize(40)
        
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            referenceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            referenceButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            motionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            motionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            left.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            left.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            
            right.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            right.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
        ])

        let scene = SCNScene(named: "head.obj")!
        
        headNode = scene.rootNode.childNodes.first

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        cameraNode.position = SCNVector3(x: 0, y: 0, z: 2.0)
        cameraNode.camera?.zNear = 0.05

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.darkGray
        sceneView.bringSubviewToFront(referenceButton)
        referenceButton.addTarget(self, action: #selector(referenceFrameButtonWasTapped), for: .touchUpInside)
        sceneView.bringSubviewToFront(motionButton)
        motionButton.addTarget(self, action: #selector(startMotionTrackingButtonTapped), for: .touchUpInside)

        motionManager.delegate = self
        
        updateButtonState()
    }
    
    private func updateButtonState() {
        motionButton.isEnabled = motionManager.isDeviceMotionAvailable
                              && CMHeadphoneMotionManager.authorizationStatus() != .denied
        let motionTitle = motionManager.isDeviceMotionActive ? "结束追踪" : "开始追踪"
        motionButton.setTitle(motionTitle, for: [.normal])
        referenceButton.isHidden = !motionManager.isDeviceMotionActive
    }
    
    private func toggleTracking() {
        switch CMHeadphoneMotionManager.authorizationStatus() {
        case .authorized:
            print("User previously allowed motion tracking")
        case .restricted:
            print("User access to motion updates is restricted")
        case .denied:
            print("User denied access to motion updates; will not start motion tracking")
            return
        case .notDetermined:
            print("Permission for device motion tracking unknown; will prompt for access")
        default:
            break
        }
        
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
        updateButtonState()
    }
    
    // MARK: - UIViewController
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    // MARK: - IBActions

    @IBAction func startMotionTrackingButtonTapped(_ sender: UIButton)
    {
        toggleTracking()
    }
    
    @IBAction func referenceFrameButtonWasTapped(_ sender: UIButton)
    {
        if let deviceMotion = motionManager.deviceMotion {
            referenceFrame = float4x4(rotationMatrix: deviceMotion.attitude.rotationMatrix).inverse
            pitchRef = deviceMotion.attitude.pitch
            yawRef = deviceMotion.attitude.yaw
            rollRef = deviceMotion.attitude.roll
        }
    }
    // MARK: - CMHeadphoneMotionManagerDelegate
    
    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        print("Headphones did connect")
        updateButtonState()
    }
    
    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        print("Headphones did disconnect")
        updateButtonState()
    }
    
    // MARK: Headphone Device Motion Handlers
    
    func headphoneMotionManager(_ motionManager: CMHeadphoneMotionManager, didUpdate deviceMotion: CMDeviceMotion) {
        let rotation = float4x4(rotationMatrix: deviceMotion.attitude.rotationMatrix)

        let mirrorTransform = simd_float4x4([
            simd_float4(-1.0, 0.0, 0.0, 0.0),
            simd_float4( 0.0, 1.0, 0.0, 0.0),
            simd_float4( 0.0, 0.0, 1.0, 0.0),
            simd_float4( 0.0, 0.0, 0.0, 1.0)
        ])

        headNode?.simdTransform = mirrorTransform * rotation * referenceFrame
        
        if abs(deviceMotion.rotationRate.z) > rateThreshold {
            if deviceMotion.rotationRate.z > 0 && deviceMotion.attitude.roll - rollRef > gapThreshold {
                left.textColor = .green
                right.textColor = .white
                label.text = ("角度: " + "\((deviceMotion.attitude.roll-rollRef))")
            } else if deviceMotion.rotationRate.z < 0 && rollRef - deviceMotion.attitude.roll > gapThreshold {
                right.textColor = .green
                left.textColor = .white
                label.text = ("角度: " + "\((deviceMotion.attitude.roll-rollRef))")
            } else {
                left.textColor = .white
                right.textColor = .white
            }
        }

        updateButtonState()
    }
    
    func headphoneMotionManager(_ motionManager: CMHeadphoneMotionManager, didFail error: Error) {
        updateButtonState()
    }
}
