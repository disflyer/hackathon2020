//
//  JKNavigationBarContainer.swift
//  AluminumKit-iOS
//
//  Created by Kael Yang on 2019/12/2.
//  Copyright © 2019 iftech.io. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit
import JasonKit

#if !AluminumKitCocoaPods
import Utilities
#endif

public protocol JKNavigationBarContainer: class {
    var navigationBarEnabled: Bool { get set }
    var shouldAddBackButton: Bool { get set }

    var navigationBarTopMargin: CGFloat { get }

    var disposeBag: DisposeBag { get }

    var jkNavigationBar: JKNavigationBar? { get set }

    func didTapBackButton(_ sender: UIButton)
}

extension JKNavigationBarContainer {
    var topDangerMargin: CGFloat { return statusBarHeight }
}

extension JKNavigationBarContainer {
    public var navigationTitle: String? {
        get {
            return jkNavigationBar?.titleLabel.attributedText?.string ?? jkNavigationBar?.titleLabel.text
        }
        set {
            jkNavigationBar?.titleLabel.attributedText = newValue?.withAttributes(JKNavigationBarConfig.titleDefaultAttributes)
        }
    }

    public func addNavigationBar(toViewIfNeeded view: UIView) {
        guard self.navigationBarEnabled else {
            return
        }

        guard self.jkNavigationBar == nil else {
            return
        }

        let newNavigationBar = JKNavigationBar()
        view.addSubview(newNavigationBar)

        newNavigationBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44 + self.navigationBarTopMargin)
        self.jkNavigationBar = newNavigationBar

        if self.shouldAddBackButton {
            self.addNavigationBarBackButton()
        }
    }

    public func addNavigationBarBackButton() {
        guard let navigationBar = self.jkNavigationBar else {
            return
        }

        navigationBar.backButton.rx.tap.subscribe(onNext: { [weak navigationBar, weak self] in
            guard let navigationBar = navigationBar else {
                return
            }
            self?.didTapBackButton(navigationBar.backButton)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.disposeBag)

        navigationBar.setLeftItems([navigationBar.backButton])
    }
}

extension JKNavigationBarContainer where Self: UIViewController {
    public var jkNavigationController: JKNavigationController? {
        return self.navigationController as? JKNavigationController
    }

    public func didTapBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    public func addNavigationBarIfNeeded() {
        self.addNavigationBar(toViewIfNeeded: self.view)
    }
}
