//
//  Extension.swift
//  MarkupAssistant
//
//  Created by apple on 5/4/20.
//  Copyright © 2020 SmartItFarmer. All rights reserved.
//

import UIKit

public enum StyleType {
    case myForm
}

public extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue  = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    public static var reuseIdentifier: String {
        return "\(self)"
    }
}

extension UITableViewCell: ReusableView {}

public protocol NibLoadable: ReusableView {
    static var nib: UINib { get }
}

extension NibLoadable {
    public static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}

extension UITableView {
    public func registerNibCell<T: NibLoadable>(ofType: T.Type) {
        self.register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueRegisteredCell<T: ReusableView>(oftype: T.Type, at indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath)
        return cell as! T //Should be safe to force unwrap since reuse ID is derived from class name
    }
}

public extension KeyedDecodingContainer {
    func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T {
        return try self.decode(T.self, forKey: key)
    }

    func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
        return try decodeIfPresent(T.self, forKey: key)
    }
}

public extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension UINavigationController {
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}

public extension UIButton {
    func asTextField() {
        self.backgroundColor = H.c(0xFE7EAD)
        self.layer.cornerRadius = 25
    }

    func asTextField1(style: StyleType) {
        self.backgroundColor = H.c(0xF4F4F4)
        self.layer.cornerRadius = 30
        self.contentHorizontalAlignment = .right
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    }

    func setGradientLayer(startColor: UIColor, endColor: UIColor, startPoint : CGPoint, endPoint: CGPoint){
        let caGradientLayer:CAGradientLayer = CAGradientLayer()
          caGradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        caGradientLayer.locations = [0, 1]
                caGradientLayer.startPoint = startPoint
                caGradientLayer.endPoint = endPoint
                caGradientLayer.frame = self.bounds
        self.layer.insertSublayer(caGradientLayer, at: 0)
        self.layer.masksToBounds = true
    }

    func asNormal(text: String) {
        //self.setText(text, style: .homeSegment)
        self.setTitle(text, for: .normal)
        self.setTitleColor(UIColor(hex: 0xffffff, alpha: 0.3), for: .normal)
    }

    func asSelect(text: String) {
        //self.setText(text, style: .homeSegment)
        self.setTitle(text, for: .normal)
        self.setTitleColor(UIColor(hex: 0xffffff, alpha: 1.0), for: .normal)
    }

    func asNormal(text: String, color: UIColor) {
        self.setTitle(text, for: .normal)
        self.setTitleColor(UIColor(hex: 0x000000, alpha: 0.3), for: .normal)
    }

    func asSelect(text: String, color: UIColor) {
        self.setTitle(text, for: .normal)
        self.setTitleColor(UIColor(hex: 0x000000, alpha: 1.0), for: .normal)
    }

}

extension UITextField {
    public func asTextField() {
        self.backgroundColor = H.c(0xFE7EAD)
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.cornerRadius = 25
//        self.borderStyle = .roundedRect
        self.textColor = H.c(0xffffff)
    }

    public func asTextField1(style: StyleType) {
        self.backgroundColor = H.c(0xF4F4F4)
        self.layer.cornerRadius = 30
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.borderStyle = .none
        self.textColor = H.c(0x000000)
    }
}

public extension NotificationCenter {
    func reinstall(observer: NSObject, name: Notification.Name, selector: Selector) {
        NotificationCenter.default.removeObserver(observer, name: name, object: nil)
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
}

public extension URL {
    var parametersFromQueryString : [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

public extension UIView {
    /// Remove all subview
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    /// Remove all subview with specific type
    func removeAllSubviews<T: UIView>(type: T.Type) {
        subviews
            .filter { $0.isMember(of: type) }
            .forEach { $0.removeFromSuperview() }
    }
}

public extension Date {
    func dateString(_ format: String = "YYYY/MM/dd, hh:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    func dateByAddingYears(_ dYears: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
}

public extension Notification.Name {
    static let LoggedIn = NSNotification.Name("LoggedIn")
    static let LoggedOut = NSNotification.Name("LoggedOut")
    static let BecameActived = NSNotification.Name("BecameActived")
}
