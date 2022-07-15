//
//  StoryboardLoadable.swift
//  McD MOP
//
//  Created by Plexure Developer on 11/10/18.
//  Copyright © 2018 Plexure. All rights reserved.
//

import UIKit

protocol StoryboardLoadable {
    func storyboardName() -> String
    func identifier() -> String
    static func initFromStoryboard() -> Self
}

extension StoryboardLoadable where Self: UIViewController {
    static func initFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: Self.init().storyboardName(), bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: Self.init().identifier()) as! Self
    }
}
