//
//  JKNavigationBar.swift
//  AluminumKit-iOS
//
//  Created by Kael Yang on 2019/12/2.
//  Copyright © 2019 iftech.io. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

public class JKNavigationBar: UIView {
    lazy private(set) var contentView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.right.bottom.equalToSuperview()
        }
        return view
    }()

    public lazy private(set) var titleLabel: UILabel = {
        let label = UILabel()
        self.setTitleView(label)

        return label
    }()

    public let backButton: UIButton = {
        let button = UIButton()
        button.setImage(JKNavigationBarConfig.backButtonImage, for: .normal)
        button.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        return button
    }()

    public lazy private(set) var leftItemContainer: UIView = {
        let view = UIView()
        self.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
        return view
    }()

    public lazy private(set) var rightItemContainer: UIView = {
        let view = UIView()
        self.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
        return view
    }()

    public var buttonTintColor = UIColor.blue {
        didSet {
            backButton.tintColor = buttonTintColor
        }
    }

    public var titleView: UIView?

    public enum TitleViewAlignment {
        case center
        case expanded
    }

    public func setTitleView(_ view: UIView?, align: TitleViewAlignment = .center) {
        self.titleView?.removeFromSuperview()
        self.titleView = view

        guard let view = view else {
            return
        }

        self.contentView.addSubview(view)

        switch align {
        case .center:
            view.snp.makeConstraints { make in
                make.left.greaterThanOrEqualTo(leftItemContainer.snp.right).offset(15)
                make.right.lessThanOrEqualTo(rightItemContainer.snp.left).offset(-15)
                make.centerY.equalToSuperview()
                make.centerX.equalToSuperview()
            }
        case .expanded:
            view.snp.makeConstraints { make in
                make.left.equalTo(leftItemContainer.snp.right).offset(15)
                make.right.equalTo(rightItemContainer.snp.left).offset(-15)
                make.centerY.equalToSuperview()
            }
        }
    }

    public func setLeftItems(_ items: [UIView], itemSpacing: CGFloat = 24) {
        self.leftItemContainer.subviews.forEach { $0.removeFromSuperview() }

        _ = items.reduce(nil, { lastView, currentItem -> UIView? in
            currentItem.tintColor = self.buttonTintColor

            self.leftItemContainer.addSubview(currentItem)

            currentItem.snp.makeConstraints { make in
                if let lastView = lastView {
                    make.left.equalTo(lastView).offset(itemSpacing)
                } else {
                    make.left.equalToSuperview()
                }
                make.centerY.equalToSuperview()
            }

            return currentItem
        })

        items.last?.snp.makeConstraints { make in
            make.right.equalToSuperview()
        }
    }

    public func setRightItems(_ items: [UIView], itemSpacing: CGFloat = 24) {
        self.rightItemContainer.subviews.forEach { $0.removeFromSuperview() }

        _ = items.reduce(nil, { lastView, currentItem -> UIView? in
            currentItem.tintColor = self.buttonTintColor

            self.rightItemContainer.addSubview(currentItem)

            currentItem.snp.makeConstraints { make in
                if let lastView = lastView {
                    make.left.equalTo(lastView.snp.right).offset(itemSpacing)
                } else {
                    make.left.equalToSuperview()
                }
                make.centerY.equalToSuperview()
            }

            return currentItem
        })

        items.last?.snp.makeConstraints { make in
            make.right.equalToSuperview()
        }
    }
}
