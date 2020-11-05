//
//  LoadingProgressBar.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/4/23.
//  Copyright © 2020 iftech. All rights reserved.
//

import UIKit

public class LoadingProgressBar: UIView {

    var progressHighlightBar = UIView()

    var progress: Double = 0 {
        didSet {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self = self else { return }

                switch self.progress {
                case ..<0.1:
                    self.show()
                case 0.9...:
                    self.hide()
                default:
                    break
                }
                self.progressHighlightBar.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: self.bounds.size.width * CGFloat(self.progress),
                    height: self.bounds.size.height)
            }
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = JKWebViewController.Theme.progressBarBackgroundColor
        progressHighlightBar.backgroundColor = JKWebViewController.Theme.progressBarHighlightColor

        self.addSubview(progressHighlightBar)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hide() {
        guard self.alpha >= 1 else { return }
        self.alpha = 0
    }

    func show() {
        guard self.alpha <= 0 else { return }
        self.alpha = 1
    }

}
