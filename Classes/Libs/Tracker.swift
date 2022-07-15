//
//  Tracker.swift
//  BabyWeatherManager
//
//  Created by shuai on 2022/1/21.
//

import UIKit

var showTracker = false

public protocol TrackSender {
    func sendEvent(name: String)
}
    
public class Tracker: NSObject {
    static var sender: TrackSender!
    
    public class func setSender(sender: TrackSender) {
        self.sender = sender
    }

    @objc public class func enable() {
        print("showTracker", showTracker)

        if showTracker {
            return
        }
        showTracker = true
        vlog("Start", [:])
    }
    
    @objc public class func sendEvent(eventName: String) {
        //TODO
//        BaiduMobStat.default().logEvent(eventName)
        
        self.sender.sendEvent(name: eventName)
        Tracker.vlog("sendEvent: \(eventName)", [:])
    }

    @objc public class func sendEvent(eventName: String, params: [String: Any]? = nil) {
        //TODO
//        BaiduMobStat.default().logEvent(eventName, attributes: params)
        Tracker.vlog("sendEvent: \(eventName)", params ?? [:])
    }

    @objc class func vlog(_ name: String, _ params: [String: Any]) {
        #if DEBUG
        if !showTracker { return }

        DispatchQueue.main.async {
            guard let win = H.win() else {
                return
            }
            var scrollView = win.viewWithTag(10000) as? UIScrollView
            var button = win.viewWithTag(10002) as? UIButton
            var clean = win.viewWithTag(10003) as? UIButton
            let sortParams = params.sorted { $0.0 < $1.0 }
            var paramsValues: [String] = []
            sortParams.forEach { (k, v) in
                paramsValues.append("\(k): \(v)")
            }
            let paramsValue = paramsValues.joined(separator: ", ")
            if scrollView == nil {
                let height = min(H.winHeight() * 0.4, 300)
                scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: H.width(win), height: height))
                //scrollView!.layer.cornerRadius = 15
                scrollView!.tag = 10000
                scrollView!.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                scrollView!.contentSize = CGSize(width: H.width(win), height: 10000)
                let textView = UITextView(frame: CGRect(x: 0, y: 0, width: H.width(win), height: 10000))
                textView.backgroundColor = UIColor.clear
                textView.textColor = UIColor.green
                textView.isEditable = false
                textView.text = "[Baidu] \(name); Params: \(paramsValue)"
                textView.tag = 10001
                scrollView!.addSubview(textView)
                win.addSubview(scrollView!)
                button = UIButton(frame: CGRect(x: H.winWidth() - 50, y: height - 50, width: 50, height: 50))
                button!.setImage(UIImage(named: "ico_close_event"), for: .normal)
                button!.addTarget(self, action: #selector(Tracker.toggleVlog), for: .touchUpInside)
                button!.tag = 10002
                win.addSubview(button!)
                clean = UIButton(frame: CGRect(x: H.winWidth() - 50, y: height - 100, width: 50, height: 50))
                clean!.setImage(UIImage(named: "ico_delete_event"), for: .normal)
                clean!.addTarget(self, action: #selector(Tracker.cleanVlog), for: .touchUpInside)
                clean!.tag = 10003
                win.addSubview(clean!)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                win.bringSubviewToFront(scrollView!)
                win.bringSubviewToFront(button!)
                win.bringSubviewToFront(clean!)
            }
            if scrollView!.isHidden {
                toggleVlog()
            }
            guard let textView = scrollView!.viewWithTag(10001) as? UITextView else { return }
            textView.text = "[Baidu] \(name); Params: \(paramsValue)\n\n" + textView.text
        }
        #endif
    }
    
    @objc class func toggleVlog() {
        var findWin: UIWindow?
        UIApplication.shared.windows.forEach { (w) in
            if w.viewWithTag(10000) != nil {
                findWin = w
            }
        }
        guard let win = findWin else { return }
        guard let scrollView = win.viewWithTag(10000) as? UIScrollView else { return }
        guard let button = win.viewWithTag(10002) as? UIButton else { return }
        guard let clean = win.viewWithTag(10003) as? UIButton else { return }
        let height = min(H.winHeight() * 0.4, 300)
        if scrollView.isHidden {
            clean.isHidden = false
            scrollView.isHidden = false
            button.setImage(UIImage(named: "ico_close_event"), for: .normal)
            button.frame = CGRect(x: H.winWidth() - 50, y: height - 50, width: 50, height: 50)
        } else {
            clean.isHidden = true
            scrollView.isHidden = true
            button.setImage(UIImage(named: "ico_plus"), for: .normal)
            button.frame = CGRect(x: H.winWidth() - 150, y: 30, width: 50, height: 50)
        }
    }
    
    @objc class func cleanVlog() {
        var findWin: UIWindow?
        UIApplication.shared.windows.forEach { (w) in
            if w.viewWithTag(10000) != nil {
                findWin = w
            }
        }
        guard let win = findWin else { return }
        guard let scrollView = win.viewWithTag(10000) as? UIScrollView else { return }
        guard let textView = scrollView.viewWithTag(10001) as? UITextView else { return }
        textView.text = ""
    }
}
