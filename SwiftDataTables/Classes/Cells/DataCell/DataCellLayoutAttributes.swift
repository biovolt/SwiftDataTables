//
//  DataCellLayoutAttributes.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 24/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

open class DataCellLayoutAttributes: UICollectionViewLayoutAttributes {
    // MARK: - Properties

    var xPositionRunningTotal: CGFloat?
    var yPositionRunningTotal: CGFloat?

    // MARK: - Lifecycle

    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! DataCellLayoutAttributes
        copy.xPositionRunningTotal = xPositionRunningTotal
        copy.yPositionRunningTotal = yPositionRunningTotal
        return copy
    }
}
