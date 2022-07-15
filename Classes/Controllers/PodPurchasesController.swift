//
//  PodPurchasesController.swift
//  BabyWeatherManager
//
//  Created by shuai on 2022/1/21.
//

import UIKit
import WebKit
import StoreKit
import SCLAlertView

open class PodPurchasesController: UIViewController {
    public static var kProductID : String = ""
    public var productRequest: SKProductsRequest!
    @IBOutlet weak open var vWebHolder: UIView!
    public var webView: WKWebView!
    open var dataManager: DataManager.Type = DataManager.self

    // MARK: - Variables
    public static var urlStringName: String = ""
    public var webTitle: String = ""
    public var source: String = ""
    public var purchaseSuccess: (() -> ())?
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.webTitle
        if PodPurchasesController.urlStringName.isEmpty {
            let identifierString = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
            PodPurchasesController.urlStringName = identifierString.lowercased()
        }
        let urlString = "https://oss.douwantech.com/purchases/\(PodPurchasesController.urlStringName).html?lang=\(H.isEn() ? "en" : "zh")&\(arc4random())"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView = WKWebView(frame: self.view.bounds)
        webView.navigationDelegate = self
        webView?.load(request)
        self.view.addSubview(webView)
        Tracker.sendEvent(eventName: "购买页面-显示(\(source))")
        Tracker.sendEvent(eventName: "购买页面-显示", params: ["source" : "\(source)"])
    }
    
    func clickClose() {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: .Purchased, object: nil)
        }
    }
}

extension PodPurchasesController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        let scheme = url.scheme ?? ""
        let host = url.host ?? ""
        
        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyObject],
            let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String] else {
            return
        }
        guard let urlScheme = urlSchemes.first else {
            return
        }

        if scheme != urlScheme {
            decisionHandler(.allow)
            return
        }
        
        switch host {
        case "share":
            self.share()
        case "rate":
            self.rate()
        case "close":
            Tracker.sendEvent(eventName: "购买页面-点击返回")
            self.clickClose()
        case "dopay":
            self.doPay()
        case "restore":
            self.restore()
        case "unlockUrl":
            guard let unlock_url = url.query else {
                decisionHandler(.cancel)
                return
            }
            self.unlockUrl(urlString: unlock_url)
        case "downapp":
            self.downapp(url: url )
        default:
            guard let parameters = url.parametersFromQueryString else { return }
            guard let openUrlString = parameters["url"] else {
                decisionHandler(.cancel)
                return
            }
            guard let openUrl = URL(string: openUrlString) else {
                decisionHandler(.cancel)
                return
            }
            if openUrl.absoluteString.hasPrefix("http") {
                if UIApplication.shared.canOpenURL(openUrl){
                    UIApplication.shared.open(openUrl, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }
            break
        }
        decisionHandler(.cancel)
        return
        
    }
}

extension PodPurchasesController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    open func downapp(url: URL) {
        guard let parameters = url.parametersFromQueryString else { return }
        guard let openUrlString = parameters["url"] else { return }
        guard let verifyUrlString = parameters["verify"] else { return }
        guard let openUrl = URL(string: openUrlString) else { return }
        guard let verifyUrl = URL(string: verifyUrlString)else { return }
        
        
        let alertView = SCLAlertView(appearance: H.alertAppearance())
        alertView.addButton("先下载APP") {
            Tracker.sendEvent(eventName: "click_down_app")
            if UIApplication.shared.canOpenURL(openUrl){
                UIApplication.shared.open(openUrl, options: [:], completionHandler: nil)
            }
        }
        alertView.addButton("后验证解锁") {
            Tracker.sendEvent(eventName: "click_unlock")
            if UIApplication.shared.canOpenURL(verifyUrl){
                self.unLockVip() {
                    self.purchaseSuccess?()
                    self.clickClose()
                }
            } else {
                H.info("对不起您还没下载APP")
            }
        }
        alertView.showInfo("", subTitle: "请小主先下载APP后然后在点击验证解锁", closeButtonTitle: H.t("common.ok"))
    }
    
    open func unlockUrl(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url){
            self.unLockVip() {
                self.purchaseSuccess?()
                self.clickClose()
            }
        }
    }
    
    open func doPayment() {
        self.unLockVip() {
            self.purchaseSuccess?()
            self.clickClose()
        }
    }
    
    open func doPay() {
        Tracker.sendEvent(eventName: "购买页面-点击购买(\(source))")
        Tracker.sendEvent(eventName: "购买页面-点击购买", params: ["source" : "\(source)"])
        LoadingManager.show()
        if SKPaymentQueue.canMakePayments() {
            let productIDs = [PodPurchasesController.kProductID]
            let productIdentifiers = Set<String>(productIDs)
            self.productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            self.productRequest.delegate = self
            self.productRequest.start()
        } else {
            print(H.t("buy.faliure_and_contact"))
        }
    }
    
    open func rate() {
        self.unLockVip() {
            self.purchaseSuccess?()
            self.clickClose()
        }
        H.rating()
    }
    
    open func share() {
        ShareManager.shared.shareView(view: self.view, callback: { controller in
            self.present(controller, animated: true, completion: { () in
                self.unLockVip() {
                    self.purchaseSuccess?()
                    self.clickClose()
                }
            })
        })
    }
    
    open func restore() {
        Tracker.sendEvent(eventName: "购买页面-恢复购买(\(source))")
        Tracker.sendEvent(eventName: "购买页面-恢复购买", params: ["source" : "\(source)"])
        LoadingManager.show()
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        else {
            LoadingManager.hide()
            print(H.t("buy.faliure_and_contact"))
        }
    }
    
    open func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            let product = response.products[0]
            if product.productIdentifier.isEqual(PodPurchasesController.kProductID) {
                SKPaymentQueue.default().add(SKPayment(product: product))
                SKPaymentQueue.default().add(self)
            }
        }
        else {
            DispatchQueue.main.async {
                LoadingManager.hide()
                H.info(H.t("buy.faliure_and_contact"))
            }
        }
    }
    
    open func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .failed:
                Tracker.sendEvent(eventName: "购买页面-支付失败(\(source))")
                Tracker.sendEvent(eventName: "购买页面-支付失败", params: ["source" : "\(source)"])
                LoadingManager.hide()
                SKPaymentQueue.default().finishTransaction(transaction)
                H.info(H.t("buy.failure_and_retry"))
            case .purchased:
                Tracker.sendEvent(eventName: "购买页面-支付成功(\(source))")
                Tracker.sendEvent(eventName: "购买页面-支付成功", params: ["source" : "\(source)"])
                SKPaymentQueue.default().finishTransaction(transaction)
                self.doPayment()
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    open func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("received restored transactions: \(queue.transactions.count)")
        if queue.transactions.count == 0 {
            H.error(H.t("buy.failure_and_restore"))
        }
        for pay:SKPaymentTransaction in queue.transactions {
            let productID = pay.payment.productIdentifier
            print("message: \(productID)")
            if PodPurchasesController.kProductID == productID {
                Tracker.sendEvent(eventName: "payment.pay_restore", params: ["source" : "\(source)"])
                doPayment()
            }
        }
        LoadingManager.hide()
    }
    
    open func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("错误恢复 code: (error)")
    }
    
    open func unLockVip(callback: @escaping(() -> Void)) {
        LoadingManager.hide()
        dataManager.shared.userUpdate(params: ["vip_days": "1000"]) { (data, error) in
            if error != nil {
                H.error(H.t("buy.faliure_upgrade_vip"))
                Tracker.sendEvent(eventName: "unlock_failed")
                return
            }
            UserBase.current.saveAsCurrent(data: data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                Tracker.sendEvent(eventName: "unlock_successful")
                H.success(H.t("buy.purchased_upgrade_vip")) {
                    callback()
                }
            }
        }
    }
}

extension Notification.Name {
    static public let Purchased = NSNotification.Name("Purchased")
}
