//
//  H.swift
//  MarkupAssistant
//
//  Created by apple on 5/4/20.
//  Copyright © 2020 SmartItFarmer. All rights reserved.
//

import UIKit
import StoreKit
import SDWebImage
import SCLAlertView

public class H: NSObject {
    public class func winWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    public class func winHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public class func alertAppearance(showCloseButton: Bool = true) -> SCLAlertView.SCLAppearance {
        return SCLAlertView.SCLAppearance(
            kCircleTopPosition: -8,
            kCircleBackgroundTopPosition: -8,
            kCircleHeight: 36,
            kCircleIconHeight: 16,
            kTitleHeight: 0,
            showCloseButton: showCloseButton
        )
    }

    public class func info(_ content: String) {
        let alertView = SCLAlertView(appearance: H.alertAppearance())
        alertView.showInfo("", subTitle: content, closeButtonTitle: H.t("common.ok"))
    }
    
    public class func success(_ content: String, _ action: @escaping (() -> Void)) {
        let appearance = SCLAlertView.SCLAppearance(
            kCircleTopPosition: -8,
            kCircleBackgroundTopPosition: -8,
            kCircleHeight: 36,
            kCircleIconHeight: 16,
            kTitleHeight: 0,
            showCloseButton: false
        )

        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton(H.t("common.ok"), action: action)
        alertView.showSuccess(content, subTitle: content)
    }
    
    public class func error(_ message: String?) {
        let alertView = SCLAlertView(appearance: H.alertAppearance())
        alertView.showError("", subTitle: message ?? "Error", closeButtonTitle: "取消")
    }

    @objc class func info(_ content: String, cancelTitle cancel:String, confirmTitle confirm:String, _ action: @escaping (() -> Void)) {
        let alertView = SCLAlertView(appearance: H.alertAppearance())
        alertView.addButton(confirm, action: action)
        alertView.showInfo("", subTitle: content, closeButtonTitle: cancel)
    }

    public class func error(_ message: String, cancelTitle cancel:String, confirmTitle confirm:String, _ action: @escaping (() -> Void)) {
        let alertView = SCLAlertView(appearance: H.alertAppearance())
        alertView.addButton(confirm, action: action)
        alertView.showError("", subTitle: message, closeButtonTitle: cancel)
    }

    public class func t(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    public class func tt(_ key: String, args: [CVarArg]) -> String {
        return String(format: NSLocalizedString(key, comment: ""), arguments: args)
    }
    
    public class func width(_ view: UIView) -> CGFloat {
        return view.frame.size.width
    }

    public class func height(_ view: UIView) -> CGFloat {
        return view.frame.size.height
    }

    public class func top(_ view: UIView) -> CGFloat {
        return view.frame.origin.y
    }

    public class func bottom(_ view: UIView) -> CGFloat {
        return view.frame.origin.y + view.frame.size.height
    }

    public class func left(_ view: UIView) -> CGFloat {
        return view.frame.origin.x
    }

    public class func right(_ view: UIView) -> CGFloat {
        return view.frame.origin.x + view.frame.size.width
    }
    
    public class func showShadow(_ v: UIView) {
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        v.layer.shadowRadius = 2
        v.layer.shadowOpacity = 0.2
        v.clipsToBounds = false
        v.superview?.clipsToBounds = false
    }
    
    public class func showShadow(_ v: UIView, width: CGFloat, height: CGFloat, radius: CGFloat, opacity: Float) {
        v.layer.shadowOffset = CGSize(width: width, height: height)
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowRadius = radius
        v.layer.shadowOpacity = opacity
    }

    public class func calTextHeight(_ text: String, _ size: CGFloat, _ width: CGFloat, _ lineHeight: CGFloat = 0) -> CGFloat {
        let font = UIFont.systemFont(ofSize: size)
        let textString = text as NSString
        var textAttributes: [String: Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        let paragraphStyle = NSMutableParagraphStyle()
        if lineHeight > 0 {
            //paragraphStyle.lineSpacing = 5
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineHeightMultiple = lineHeight / UIFont.systemFont(ofSize: size).lineHeight
            textAttributes[convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle)] = paragraphStyle
        }
        let r = textString.boundingRect(with: CGSize(width: width, height: 500), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(textAttributes), context: nil)
        return max(lineHeight, r.size.height)
    }
    
    public class func calTextWidth(_ text: String, _ size: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: size)
        let textAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        let r = text.boundingRect(with: CGSize(width: 500, height: 500), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(textAttributes), context: nil)
        return r.size.width
    }

    public class func c(_ hex: Int) -> UIColor {
        return UIColor(hex: hex)
    }
    
    public class func c(_ values: [CGFloat]) -> UIColor {
        return UIColor(red: values[0]/255.0, green: values[1]/255.0, blue: values[2]/255.0, alpha: values[3])
    }

    public class func statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return statusBarHeight
    }

    public class func extraBottomHeight() -> CGFloat {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        return window?.safeAreaInsets.bottom ?? 0
    }

    public class func win() -> UIWindow? {
        var wdow: UIWindow? = nil
        if #available(iOS 13.0, *) {
            if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                guard let window = currentWindowScene.windows.first else {
                    return nil
                }
                wdow = window
            }
        }else{
            guard let appDelegate = UIApplication.shared.delegate else {
                return nil
            }
            guard let window = appDelegate.window else {
                return nil
            }
            wdow = window
        }
        return wdow
    }

    public class func loadImage(_ imageView: UIImageView, _ url: String, _ placeholder: String = "ico_default") {
        let placeholderImage = UIImage(named: placeholder)
        imageView.sd_setImage(with: URL(string: url), placeholderImage: placeholderImage, options: .refreshCached)
    }

    public class func isIphone5AndLow() -> Bool {
        return UIScreen.main.bounds.size.height <= 568
    }
    
    public class func isIphone6AndLow() -> Bool {
        return UIScreen.main.bounds.size.height <= 667
    }
    
    public class func isIphoneXAndHigh() -> Bool {
        return UIScreen.main.bounds.size.height >= 736
    }
    
    public class func isIOS10AndLow() -> Bool {
        if #available(iOS 11.0, *) {
            return false
        } else {
            return true
        }
    }
    
    public class func isIOS12AndLow() -> Bool {
        if #available(iOS 13.0, *) {
            return false
        } else {
            return true
        }
    }
    
    public class func isFullScreen() -> Bool {
        if extraBottomHeight() > 0 {
            return true
        }
        return false
    }
        
    public class func appVersion() -> String {
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(versionString).\(buildString)"
    }
    
    public class func rating() {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        } else {
            guard let url = URL(string: "") else { return }
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    public class func isEn() -> Bool {
        if isIOS10AndLow() {
            if (Locale.current.languageCode ?? "") == "en" {
                return true
            }
            return (Bundle.main.preferredLocalizations.last ?? "") == "en"
        }
        return (Locale.current.languageCode ?? "") == "en"
    }
    
    public class func isIpad() -> Bool {
        return (UIDevice.current.userInterfaceIdiom == .pad)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
