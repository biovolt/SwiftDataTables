//
//  DataTableConfiguration.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public enum DataStyles {
    public enum Colors {
        public static var highlightedSecondColor: UIColor = setupColor(normalColor: UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1),
                                                                       darkColor: UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1),
                                                                       defaultColor: UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1))

        public static var highlightedFirstColor: UIColor = setupColor(normalColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1),
                                                                      darkColor: UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1),
                                                                      defaultColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1))

        public static var unhighlightedSecondColor: UIColor = setupColor(normalColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1),
                                                                         darkColor: UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1),
                                                                         defaultColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1))

        public static var unhighlightedFirstColor: UIColor = setupColor(normalColor: .white,
                                                                        darkColor: UIColor(red: 0.03, green: 0.03, blue: 0.03, alpha: 1),
                                                                        defaultColor: .white)
    }
}

public let Style = DataStyles.self

private func setupColor(normalColor: UIColor, darkColor: UIColor, defaultColor: UIColor) -> UIColor {
    if #available(iOS 13, *) {
        return UIColor.init { trait -> UIColor in
            if trait.userInterfaceStyle == .dark {
                return darkColor
            } else {
                return normalColor
            }
        }
    } else {
        return defaultColor
    }
}

public struct DataTableColumnOrder: Equatable {
    // MARK: - Properties

    let index: Int
    let order: DataTableSortType
    public init(index: Int, order: DataTableSortType) {
        self.index = index
        self.order = order
    }
}

public struct DataTableConfiguration: Equatable {
    public var defaultOrdering: DataTableColumnOrder?
    public var heightForSectionFooter: CGFloat = 44
    public var heightForSectionHeader: CGFloat = 44
    public var heightForSearchView: CGFloat = 60
    public var heightOfInterRowSpacing: CGFloat = 1

    public var shouldShowFooter: Bool = true
    public var shouldShowSearchSection: Bool = true
    public var shouldSearchHeaderFloat: Bool = false
    public var shouldSectionFootersFloat: Bool = true
    public var shouldSectionFootersShow: Bool = true
    public var shouldSectionHeadersFloat: Bool = true
    public var shouldContentWidthScaleToFillFrame: Bool = true

    public var shouldShowVerticalScrollBars: Bool = true
    public var shouldShowHorizontalScrollBars: Bool = false

    public var sortArrowTintColor: UIColor = .blue

    public var shouldSupportRightToLeftInterfaceDirection: Bool = true

    public var highlightedAlternatingRowColors = [
        DataStyles.Colors.highlightedFirstColor,
        DataStyles.Colors.highlightedSecondColor
    ]
    public var unhighlightedAlternatingRowColors = [
        DataStyles.Colors.unhighlightedFirstColor,
        DataStyles.Colors.unhighlightedSecondColor
    ]

    public var fixedColumns: DataTableFixedColumnType?
    internal var fontForRows: UIFont = UIFont.systemFont(ofSize: 12)
    internal var colorForLinkTextInRows = UIColor.blue
    internal var colorForTextInRows = UIColor.black
    internal var fontForHeaders: UIFont = UIFont.boldSystemFont(ofSize: 16)

    public init() {}
}
