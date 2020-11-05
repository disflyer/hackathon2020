//
//  JKWebViewController.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/4/22.
//  Copyright © 2020 iftech. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import SnapKit
import JasonKit

open class JKWebViewController: UIViewController, JKHybridCallbackHandlerProtocol {
    public let disposeBag = DisposeBag()

    public var initialUrl: URL

    public var webView: WKWebView = {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.applicationNameForUserAgent = JKWebViewController.Config.applicationNameForUserAgent
        webViewConfig.preferences.setValue(true, forKey: "developerExtrasEnabled")

        webViewConfig.userContentController = WKUserContentController()

        return WKWebView(frame: CGRect.zero, configuration: webViewConfig)
    }()

    public var loadingProgressBar: LoadingProgressBar = {
        return LoadingProgressBar()
    }()

    var providerHost: String = "" {
        didSet {
            guard providerHost.length > 0 else {
                return providerHostLabel.attributedText = NSAttributedString()
            }
            providerHostLabel.attributedText = "此网页由 \(providerHost) 提供".withAttributes([
                .fontSize(12), .color(UIColor.lightGray), .align(.center),
            ])
        }
    }
    public var providerHostLabel: UILabel = {
        return UILabel()
    }()

    public init(url: URL) {
        self.initialUrl = url
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Theme.viewBackgroundColor

        self.view.addSubview(providerHostLabel)

        self.view.addSubview(webView)
        webView.isOpaque = false
        webView.backgroundColor = Theme.webViewBackgroundColor
        webView.uiDelegate = self
        webView.navigationDelegate = self

        self.view.addSubview(loadingProgressBar)

        self.layoutViews()

        webView.rx.observe(String.self, "title")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                if let title = title {
                    self?.title = title
                }
        }).disposed(by: self.disposeBag)

        webView.rx.observe(Double.self, "estimatedProgress")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] progress in
                if let progress = progress {
                    self?.webViewProgressChanged(progress: progress)
                }
        }).disposed(by: self.disposeBag)

        setupAutoAdjustProviderHostAlpha()

        self.load(initialUrl)
    }

    open func setupAutoAdjustProviderHostAlpha() {
        webView.scrollView.rx.contentOffset.subscribe(onNext: { [weak self] point in
            guard let self = self else { return }
            let realPointY: CGFloat
            if #available(iOS 11, *) {
                realPointY = point.y + self.webView.scrollView.contentInset.top + self.webView.scrollView.adjustedContentInset.top
            } else {
                realPointY = point.y + self.webView.scrollView.contentInset.top
            }
            self.providerHostLabel.alpha = max(0, min((-realPointY - 30) / 60, 1))
        }).disposed(by: self.disposeBag)
    }

    open func layoutViews() {
        providerHostLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(20)
            make.left.equalTo(self.view.snp.leftMargin).offset(10)
            make.right.equalTo(self.view.snp.rightMargin).offset(-10)
        }
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        loadingProgressBar.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(4)
        }
    }

    open func load(_ url: URL) {
        if url.isFileURL {
            DispatchQueue.main.async {
                self.webView.loadFileURL(url, allowingReadAccessTo: url)
            }
        } else {
            let request = URLRequest(url: url)
            DispatchQueue.main.async {
                self.webView.load(request)
            }
        }
    }

    open func webViewProgressChanged(progress: Double) {
        self.loadingProgressBar.progress = progress
    }

    // MARK: - Hybrid

    open func shouldInjectHybridNativeDispatch() -> Bool {
        if let scheme = self.webView.url?.scheme,
            scheme == "https",
            let matches = self.webView.url?.host?.matchingStrings(regex: Config.regexOfHostsAllowToInjectHybridCode),
            matches.count > 0 {

            return true
        } else if let scheme = self.webView.url?.scheme,
            scheme == "file",
            let pathString = self.webView.url?.path,
            FileManager.default.fileExists(atPath: pathString) {

            return true
        } else {
            return false
        }
    }
}

extension JKWebViewController {
    public struct Config {
        public static var loggerProxy: JKWebViewLogProxy.Type?
        public static var applicationNameForUserAgent = "JKWebViewKit"
        public static var regexOfHostsAllowToInjectHybridCode = #"^.*\.?.+\..+$"#
    }

    public struct Theme {
        public static var viewBackgroundColor = UIColor.white
        public static var webViewBackgroundColor = UIColor.clear
        public static var progressBarHighlightColor = UIColor.systemBlue
        public static var progressBarBackgroundColor = UIColor.clear
    }
}
