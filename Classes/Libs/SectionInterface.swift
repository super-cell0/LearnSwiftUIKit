//
//  CheckoutSectionInterface.swift
//  McDonaldsJapan
//
//  Created by apple on 11/22/19.
//  Copyright © 2019 TechFirm.inc. All rights reserved.
//

import UIKit

public protocol CellInterface {
    func name() -> String
    func calcHeight() -> CGFloat
    /*func calcHeight(wear: Wear) -> CGFloat
    func calcHeight(warning: Warning) -> CGFloat*/
}

extension CellInterface {
    /*public func calcHeight(wear: Wear) -> CGFloat {
        return 0
    }
    
    public func calcHeight(warning: Warning) -> CGFloat {
        return 0
    }*/
}

public protocol CollectionCellInterface {
    func name() -> String
    func calcSize() -> CGSize
}

public protocol SectionInterface {
    func cellAndData(indexPath: IndexPath) -> UITableViewCell
    func cellRows() -> Int
    func cellHeight(indexPath: IndexPath) -> CGFloat
    func cellDidSelect(indexPath: IndexPath)
    func cellCanEdit(indexPath: IndexPath) -> Bool
    func cellEditing(indexPath: IndexPath, style: UITableViewCell.EditingStyle)
}

extension SectionInterface {
    public func cellCanEdit(indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func cellEditing(indexPath: IndexPath, style: UITableViewCell.EditingStyle) {
    }
}

public protocol CollectionSectionInterface {
    func cellAndData(indexPath: IndexPath) -> UICollectionViewCell
    func cellRows() -> Int
    func cellSize(indexPath: IndexPath) -> CGSize
    func cellDidSelect(indexPath: IndexPath)
    func cellWillDisplay(indexPath: IndexPath)
}

extension CollectionSectionInterface {
    func cellWillDisplay(indexPath: IndexPath) {
    }
}
