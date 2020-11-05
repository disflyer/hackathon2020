//
//  ViewController.swift
//  AirPodsProMotion
//
//  Created by Yoshio on 2020/09/22.
//

import UIKit
import CoreMotion

class InformationViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    let bg: UIImageView = UIImageView()
    let Bt: UIButton = UIButton()
    lazy var textView: UITextView = {
        let view = UITextView()
        view.frame = CGRect(x: self.view.bounds.minX + (self.view.bounds.width / 10),
                            y: self.view.bounds.minY + (self.view.bounds.height / 6),
                            width: self.view.bounds.width, height: self.view.bounds.height)
        
        view.font = view.font?.withSize(14)
        view.isEditable = false
        return view
    }()
    
    
    
    //AirPods Pro => APP :)
    let APP = CMHeadphoneMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.title = "Information View"
        view.backgroundColor = .systemBackground
        view.addSubview(self.bg)
        bg.backgroundColor = UIColor.red
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.image = UIImage(named: "img1")
        Bt.backgroundColor=UIColor.red
        
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        APP.delegate = self
        
        guard APP.isDeviceMotionAvailable else { return }
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            self?.printData(motion)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        APP.stopDeviceMotionUpdates()
    }
    
    func printData(_ data: CMDeviceMotion) {
        print(data)
        self.textView.text = """
            Quaternion:
                x: \(data.attitude.quaternion.x)
                y: \(data.attitude.quaternion.y)
                z: \(data.attitude.quaternion.z)
                w: \(data.attitude.quaternion.w)
            Attitude:
                pitch: \(data.attitude.pitch)
                roll: \(data.attitude.roll)
                yaw: \(data.attitude.yaw)
            Gravitational Acceleration:
                x: \(data.gravity.x)
                y: \(data.gravity.y)
                z: \(data.gravity.z)
            Rotation Rate:
                x: \(data.rotationRate.x)
                y: \(data.rotationRate.y)
                z: \(data.rotationRate.z)
            Acceleration:
                x: \(data.userAcceleration.x)
                y: \(data.userAcceleration.y)
                z: \(data.userAcceleration.z)
            Magnetic Field:
                field: \(data.magneticField.field)
                accuracy: \(data.magneticField.accuracy)
            Heading:
                \(data.heading)
            """
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.pushViewController(HomeViewController(), animated: true)
    }
}
