//
//  EcomLoadingManager.swift
//  EcomManager
//
//  Created by apple on 2021/9/16.
//

import Foundation

import UIKit

enum LoadingSource {
    case api
    case auth
}

struct LoadingConst {
    static let viewTag = 188888
    static let dontShowTag = 188889
    static let delay = 0.5
}

public struct LoadingConfig {
    public var imagePrefix: String = "frame-"
    public var size: CGSize = CGSize(width: 60, height: 60)
    public var radius: CGFloat = 0
    public var bgColor: UIColor = .clear
    public static var shared: LoadingConfig = LoadingConfig()

    public init(imagePrefix: String, size: CGSize, radius: CGFloat, bgColor: UIColor) {
        self.imagePrefix = imagePrefix
        self.size = size
        self.radius = radius
        self.bgColor = bgColor
    }

    public init() {}
}

public class LoadingManager: NSObject {

    class func listen(_ target: NSObject, sources: [LoadingSource], show: Selector, hide: Selector) {
        sources.forEach { (source) in
            NotificationCenter.default.reinstall(observer: target, name: Notification.Name(rawValue: "LoadingShow\(source)"), selector: show)
            NotificationCenter.default.reinstall(observer: target, name: Notification.Name(rawValue: "LoadingHide\(source)"), selector: hide)
        }
    }

    class func unlisten(_ target: NSObject) {
        let sources: [LoadingSource] = [.api]
        sources.forEach { (source) in
            NotificationCenter.default.removeObserver(target, name: Notification.Name(rawValue: "LoadingShow\(source)"), object: nil)
            NotificationCenter.default.removeObserver(target, name: Notification.Name(rawValue: "LoadingHide\(source)"), object: nil)
        }
    }

    public class func show(delay: Double = 0.8, config: LoadingConfig = LoadingConfig.shared) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard let view = UIApplication.shared.keyWindow else { return }
            // If `hide` call before `show`, then don't need to display loading
            if let dontShow = view.viewWithTag(LoadingConst.dontShowTag) {
                dontShow.removeFromSuperview()
                return
            }
            let v = view.viewWithTag(LoadingConst.viewTag)
            if v != nil { return }
            let rect = view.bounds
            let frame = CGRect(x: (rect.width -  config.size.width) / 2, y: (rect.height - config.size.height) / 2, width: config.size.width, height: config.size.height)
            let imageView = UIImageView(frame: frame)
            imageView.image = UIImage.animatedImageNamed(config.imagePrefix, duration: 2)
            imageView.backgroundColor = config.bgColor
            imageView.tag = LoadingConst.viewTag
            imageView.layer.cornerRadius = config.radius
            imageView.clipsToBounds = true
            view.addSubview(imageView)
        }
    }

    public class func hide(delay: Double = 0.4) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard let view = UIApplication.shared.keyWindow else { return }
            let v = view.viewWithTag(LoadingConst.viewTag)
            if v == nil {
                // Tell show not to display loading
                let dontShow = UIView(frame: CGRect(x: -100, y: -100, width: 1, height: 1))
                dontShow.tag = LoadingConst.dontShowTag
                view.addSubview(dontShow)
                return
            }
            v?.removeFromSuperview()
        }
    }

    class func showEvent(source: LoadingSource) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LoadingShow\(source)"), object: nil, userInfo: nil)
    }

    class func hideEvent(source: LoadingSource) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LoadingHide\(source)"), object: nil, userInfo: nil)
    }
}

