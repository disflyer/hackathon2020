//
//  ViewController.swift
//  Example
//
//  Created by Arthur Wang on Apr 17, 2020.
//  Copyright © 2020 iftech. All rights reserved.
//

import UIKit
import JKWebViewKit
import AluminumKit

class ViewController: UITableViewController {

    let hybridHandler = JKAlHybridHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = .white
        self.title = "小游戏"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuse_id")

        hybridHandler.register()
        hybridHandler.enableHybridHandlers()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse_id", for: indexPath)
        cell.textLabel?.numberOfLines = 2
        switch indexPath.row {
        case 0: cell.textLabel?.text = "飞机大战"
        case 1: cell.textLabel?.text = "打砖块"
        default: break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let webviewCon = WebViewController(url: URL(string: "http://m.game.com")!)
            self.navigationController?.pushViewController(webviewCon, animated: true)
        case 1:
            let webviewCon = WebViewController(url: URL(string: "http://m.game.com")!)
            let nested = JKNavigationController(rootViewController: webviewCon)
            nested.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nested, animated: true, completion: {
                // Add custom "Done" button if you want
                let doneButton = UIButton(type: .system)
                doneButton.setTitle("Done", for: .normal)
                doneButton.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak webviewCon] in
                    webviewCon?.dismiss(animated: true, completion: nil)
                }).disposed(by: webviewCon.disposeBag)
//                webviewCon.jkNavigationBar?.setLeftItems([doneButton])
            })
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }

}
