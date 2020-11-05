//
//  JKAlWebViewController.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/5/11.
//  Copyright © 2020 iftech. All rights reserved.
//

import AluminumKit
import RxSwift

public class JKAlWebViewController: JKWebViewController, JKNavigationBarContainer {
    public var navigationBarEnabled: Bool = true
    public var shouldAddBackButton: Bool = true
    public var navigationBarTopMargin: CGFloat { return statusBarHeight }
    public var jkNavigationBar: JKNavigationBar?

    override public var title: String? {
        didSet {
            self.jkNavigationBar?.titleLabel.text = title
        }
    }

    override public func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = true
        self.addNavigationBarIfNeeded()

        super.viewDidLoad()
    }

    override public func layoutViews() {
        guard let navigationBar = self.jkNavigationBar else {
            super.layoutViews()
            return
        }
        providerHostLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(20)
            make.left.equalTo(self.view.snp.leftMargin).offset(10)
            make.right.equalTo(self.view.snp.rightMargin).offset(-10)
        }

        webView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }

        loadingProgressBar.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(4)
        }
    }

    open func didTapBackButton(_ sender: UIButton) {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
