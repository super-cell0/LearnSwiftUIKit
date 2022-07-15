//
//  ContactManager.swift
//  IdentityPhoto
//
//  Created by Mark on 2020/10/2.
//  Copyright © 2020 Mark. All rights reserved.
//

import UIKit
import ShareBubbles

public class ContactManager: NSObject {
    static public let shared = ContactManager()
    var bubbles: ShareBubbles?
    
    public func show(view: UIView) {
        bubbles = ShareBubbles(point: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2), radius: 100, in: view)
        let wechat = ShareAttirbute(bubbleId: 2, icon: UIImage(named: "ico_wechat")!, backgroundColor: UIColor.white)
        let copy = ShareAttirbute(bubbleId: 3, icon: UIImage(named: "ico_copied")!, backgroundColor: UIColor.white)
        bubbles?.customBubbleAttributes = [wechat, copy]
        bubbles?.showBubbleTypes = []
        bubbles?.delegate = self
        bubbles?.show()
    }
}

extension ContactManager: ShareBubblesDelegate {
    public func bubblesTapped(bubbles: ShareBubbles, bubbleId: Int) {
        switch bubbleId {
        case 1:
            guard let url = URL(string: "https://weibo.com/myassistant") else { return }
            UIApplication.shared.open(url, options: [:])
        case 2:
            H.info(H.tt("contactmanager.wechat", args: [H.t("contactmanager.wechat")]))
            UIPasteboard.general.string = H.t("contactmanager.wechat")
        case 3:
            let deviceID = DataManager.shared.getAccessToken()
            H.info(H.tt("contactmanager.copy", args: [deviceID]))
            UIPasteboard.general.string = String(format: "%@", deviceID)
        default:
            break
        }
    }
}

