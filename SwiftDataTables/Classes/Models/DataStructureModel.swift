//
//  DataStructureModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

// struct DataTableColumnModel {
//
// }
public struct DataStructureModel {
    // MARK: - Private Properties

    private var shouldFitTitles: Bool = true
    var columnCount: Int {
        return headerTitles.count // ?? 0
    }

    // MARK: - Public Properties

    var data = DataTableContent()
    var headerTitles = [String]()
    var footerTitles = [String]()
    var shouldFootersShowSortingElement: Bool = false
    private var headerFont: UIFont
    private var rowFont: UIFont

    private var columnAverageContentLength = [Float]()

    // MARK: - Lifecycle

    init() {
        self.init(data: DataTableContent(), headerTitles: [String](), headerFont: UIFont.systemFont(ofSize: UIFont.labelFontSize), rowFont: UIFont.systemFont(ofSize: UIFont.labelFontSize))
    }

    init(
        data: DataTableContent, headerTitles: [String],
        shouldMakeTitlesFitInColumn: Bool = true,
        shouldDisplayFooterHeaders: Bool = true,
        headerFont: UIFont?,
        rowFont: UIFont?
        // sortableColumns: [Int] // This will map onto which column can be sortable
    ) {
        self.headerFont = headerFont ?? UIFont.systemFont(ofSize: UIFont.labelFontSize)
        self.rowFont = rowFont ?? UIFont.systemFont(ofSize: UIFont.labelFontSize)

        self.headerTitles = headerTitles
        let unfilteredData = data
        let sanitisedData = unfilteredData.filter { currentRowData in
            // Trim column count for current row to the number of headers present
            let rowWithPreferredColumnCount = Array(currentRowData.prefix(upTo: self.columnCount))
            return rowWithPreferredColumnCount.count == self.columnCount
        }

        self.data = sanitisedData // sanitisedData
        shouldFitTitles = shouldMakeTitlesFitInColumn
        columnAverageContentLength = processColumnDataAverages(data: self.data)

        if shouldDisplayFooterHeaders {
            footerTitles = headerTitles
        }
    }

    public func averageColumnDataLengthTotal() -> Float {
        return Array(0 ..< headerTitles.count).reduce(0) { $0 + self.averageDataLengthForColumn(index: $1) }
    }

    public func averageDataLengthForColumn(index: Int) -> Float {
        if shouldFitTitles {
            return max(columnAverageContentLength[index], Float(headerTitles[index].widthOfString(usingFont: headerFont).rounded(.up)))
        }
        return columnAverageContentLength[index]
    }

    // extension DataStructureModel {
    // Finds the average content length in each column
    private func processColumnDataAverages(data: DataTableContent) -> [Float] {
        var columnContentAverages = [Float]()
        for column in Array(0 ..< headerTitles.count) {
            let averageForCurrentColumn = Array(0 ..< data.count).reduce(0) {
                let dataType: DataTableValueType = data[$1][column]
                return $0 + Int(dataType.stringRepresentation.widthOfString(usingFont: rowFont).rounded(.up))
            }
            columnContentAverages.append((data.count == 0) ? 1 : Float(averageForCurrentColumn) / Float(data.count))
        }
        return columnContentAverages
    }

    public func columnHeaderSortType(for index: Int) -> DataTableSortType {
        guard headerTitles[safe: index] != nil else {
            return .hidden
        }
        // Check the configuration object to see what it wants us to display otherwise return default
        return .unspecified
    }

    public func columnFooterSortType(for index: Int) -> DataTableSortType {
        guard footerTitles[safe: index] != nil else {
            return .hidden
        }
        // Check the configuration object to see what it wants us to display otherwise return default
        return .hidden
    }
}
