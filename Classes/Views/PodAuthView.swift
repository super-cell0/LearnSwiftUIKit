//
//  AuthView.swift
//  MarkupAssistant
//
//  Created by Mark on 2020/7/30.
//  Copyright © 2020 SmartItFarmer. All rights reserved.
//

import UIKit
import AuthenticationServices
import CloudKit

public protocol AuthViewDelegate: AnyObject {
    func authViewDismissed()
}

open class PodAuthView: UIView {
    static let commonViewTag = 99993
    @IBOutlet weak open var vDialogWrap: UIView!
    @IBOutlet weak open var vTitle: UILabel!
    @IBOutlet weak open var vNote: UILabel!
    @IBOutlet weak open var vContinue: UIButton!
    @IBOutlet weak open var vAppidLoginButton: UIButton!
    @IBOutlet weak open var vLogin: UIButton!
    var vContent: UIView?
    weak var delegate: AuthViewDelegate?
    open var dataManager: DataManager.Type = DataManager.self

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    open func setupView() {
        guard let view = loadViewFromNib() else { return }
        vContent = view
        vDialogWrap.layer.cornerRadius = 25
        
        /*vTitle.setText(H.t("auth.title"), style: .authLoginTitle)
        vNote.setText(H.t("auth.note"), style: .homeSearchNoResultNote)
        vContinue.setText(H.t("auth.continue"), style: .authLoginContinue)
        
        vLogin.setText(H.t("auth.appleid"), style: .appidLoginButton)*/
        vAppidLoginButton.layer.backgroundColor = UIColor(hexString: "#FF71A5").cgColor
        vAppidLoginButton.layer.cornerRadius = 20
        vAppidLoginButton.layer.masksToBounds = true
        vAppidLoginButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        vLogin.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        self.addSubview(view)
        self.alpha = 0
        LoadingManager.listen(self, sources: [.auth], show: #selector(PodAuthView.showLoading), hide: #selector(PodAuthView.hideLoading))
    }

    open func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AuthView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    @objc func handleLogInWithAppleIDButtonPress() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
        
    open override func layoutSubviews() {
        super.layoutSubviews()
        vContent?.frame = self.bounds
    }

    @IBAction func dismiss() {
        UserDefaultUtils.shared.saveItem(1, UserDefaultKey.AuthViewViewed)
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.delegate?.authViewDismissed()
        }
    }
    
    public class func show(win: UIWindow?, delegate: AuthViewDelegate? = nil, type: PodAuthView.Type) {
        guard let win = win else { return }
        let contentView = type.init(frame: CGRect(x: 0, y: 0, width: H.winWidth(), height: H.winHeight()))
        contentView.tag = PodAuthView.commonViewTag
        contentView.delegate = delegate
        win.addSubview(contentView)
        UIView.animate(withDuration: 0.3) {
            contentView.alpha = 1
        }
    }
    
    @objc func showLoading() {
        DispatchQueue.main.async {
            LoadingManager.show()
        }
    }
    
    @objc func hideLoading() {
        DispatchQueue.main.async {
            LoadingManager.hide()
        }
    }
}

@available(iOS 13.0, *)
extension PodAuthView: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        H.error(error.localizedDescription)
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let data = (authorization.credential as? ASAuthorizationAppleIDCredential)?.authorizationCode else {
            H.error("Login fail")
            return
        }
        let token = String(NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "")
        LoadingManager.showEvent(source: .auth)
        dataManager.shared.userAuth(token: token) { (data, error) in
            LoadingManager.hideEvent(source: .auth)
            if error != nil {
                H.error((error as? MyError)?.message ?? "Login fail")
                return
            }
            guard let authUser = data as? AuthUser else {
                H.error("Login fail")
                return
            }
            UserBase.current.markAsLogin(authUser: authUser)
            NotificationCenter.default.post(name: .LoggedIn, object: nil)
            DispatchQueue.main.async {
                self.dismiss()
            }
        }
    }
}
