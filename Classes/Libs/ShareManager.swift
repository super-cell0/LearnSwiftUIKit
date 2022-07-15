//
//  ShareManager.swift
//  MarkupAssistant
//
//  Created by Mark on 2020/10/22.
//  Copyright © 2020 SmartItFarmer. All rights reserved.
//


import UIKit
import SDWebImage

open class ShareManager: NSObject {
    static public let shared = ShareManager()

    public func shareView(view: UIView, content: String = H.t("share_app.title"), url: String = H.t("share_app.url"), imageUrl: String = H.t("share_app.image_url"), callback: @escaping((UIActivityViewController) -> Void))  {
        SDWebImageManager.shared.loadImage(with: URL(string: imageUrl), options: [], progress: nil) { image, _, err, type, flag, _ in
            guard let image = image else { return }
            let activityViewController = UIActivityViewController(
                activityItems: [
                    content,
                    image,
                    URL(string: url)!
                ],
                applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.mail,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.copyToPasteboard
            ];
            activityViewController.completionWithItemsHandler = {
                (activity, success, items, error) in
                if ["com.taobao.taobao4iphone.ShareExtension","com.apple.share.Flickr.post","com.apple.share.SinaWeibo.post","com.laiwang.DingTalk.ShareExtension","com.apple.mobileslideshow.StreamShareService","com.alipay.iphoneclient.ExtensionSchemeShare","com.apple.share.Facebook.post","com.apple.share.Twitter.post","com.apple.Health.HealthShareExtension","com.tencent.xin.sharetimeline","com.apple.share.TencentWeibo.post","com.tencent.mqq.ShareExtension"].contains(activity?.rawValue ?? "Not Value") {
                    //callback()
                }
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceView = view
                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            }
            callback(activityViewController)
        }
    }
}
