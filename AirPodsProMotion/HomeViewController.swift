//
//  ViewController.swift
//  AirPodsProMotion
//
//  Created by Yoshio on 2020/09/22.
//

import UIKit
import CoreMotion
import JKWebViewKit
import AluminumKit

class HomeViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    let bg: UIImageView = UIImageView()
    let Bt1: UIButton = UIButton()
    let Bt2: UIButton = UIButton()
    let Bt3: UIButton = UIButton()
    let hybridHandler = JKAlHybridHandler()
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
        hybridHandler.register()
        hybridHandler.enableHybridHandlers()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.title = "Information View"
        view.backgroundColor = .systemBackground
        view.addSubview(self.bg)
        view.addSubview(self.Bt1)
        view.addSubview(self.Bt2)
        view.addSubview(self.Bt3)
        bg.backgroundColor = UIColor.red
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.image = UIImage(named: "img2")
 
        Bt1.frame = CGRect(x: 0, y: 0, width: 1000, height: 310)
        Bt2.frame = CGRect(x: 0, y: 310, width: 1000, height: 310)
        Bt3.frame = CGRect(x: 0, y: 620, width: 1000, height: 1000)
        Bt1.addTarget(self, action: #selector(tapClick1), for: .touchUpInside)
        Bt2.addTarget(self, action: #selector(tapClick2), for: .touchUpInside)
        Bt3.addTarget(self, action: #selector(tapClick3), for: .touchUpInside)
    
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        APP.stopDeviceMotionUpdates()
    }
    @objc func tapClick1() {
        let webviewCon = WebViewController(url: URL(string: "https://static.codefuture.top/hackaton_game/aircraft_war_3/index.html")!)
        self.navigationController?.pushViewController(webviewCon, animated: true)
    }
    @objc func tapClick2() {
        let webviewCon = FireBallWebViewController(url: URL(string: "https://static.codefuture.top/hackaton_game/firing_balls_4/index.html")!)
        self.navigationController?.pushViewController(webviewCon, animated: true)
    }
    @objc func tapClick3() {
        let webviewCon = HeadphonePoseViewController()
        self.navigationController?.pushViewController(webviewCon, animated: true)
    }
    
}
