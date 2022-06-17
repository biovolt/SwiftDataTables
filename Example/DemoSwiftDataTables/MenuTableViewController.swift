//
//  MenuTableViewController.swift
//  SwiftDataTables_Example
//
//  Created by Pavan Kataria on 13/06/2018.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import SwiftDataTables
import UIKit

struct MenuItem {
    let title: String
    let config: DataTableConfiguration?

    public init(title: String, config: DataTableConfiguration? = nil) {
        self.title = title
        self.config = config
    }
}

class MenuViewController: UITableViewController {
    private enum Properties {
        enum Section {
            static let dataStore: Int = 0
            static let visualConfiguration: Int = 1
        }

        static let menuItemIdentifier: String = "MenuItemIdentifier"
    }

    lazy var menuItems: [[MenuItem]] = self.createdMenuItems()
    lazy var exampleConfigurations: [MenuItem] = self.createdExampleConfigurations()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Properties.menuItemIdentifier)
        tableView.rowHeight = 70
        tableView.reloadData()
    }

    // MARK: - Actions

    private func showDataStoreWithDataSet() {
        let instance = DataTableWithDataSetViewController()
        show(instance, sender: self)
    }

    private func showDataStoreWithDataSource() {
        let instance = DataTableWithDataSourceViewController()
        show(instance, sender: self)
        instance.addDataSourceAfter()
    }

    private func showDataStoreWithEmptyDataSet() {
        let instance = DataTableWithDataSourceViewController()
        show(instance, sender: self)
    }

    private func showGenericExample(for index: Int) {
        let menuItem = exampleConfigurations[index]
        guard let configuration = menuItem.config else {
            return
        }
        showGenericExample(with: configuration)
    }

    private func showGenericExample(with configuration: DataTableConfiguration) {
        let instance = GenericDataTableViewController(with: configuration)
        show(instance, sender: self)
    }
}

// MARK: - Data source and delegate methods

extension MenuViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return menuItems.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Properties.menuItemIdentifier, for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.section][indexPath.row].title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return cell
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Properties.Section.dataStore:
            return "Data Store variations"
        case Properties.Section.visualConfiguration:
            return "Visual configuration variations"
        default: return nil
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            showDataStoreWithDataSet()
        case (0, 1):
            showDataStoreWithDataSource()
        case (0, 2):
            showDataStoreWithEmptyDataSet()
        case (1, let row):
            showGenericExample(for: row)
        default: fatalError("An example hasn't been created for [section: \(indexPath.section) row: \(indexPath.row)]")
        }
    }
}

// MARK: - Lazily Load

extension MenuViewController {
    private func createdMenuItems() -> [[MenuItem]] {
        let sectionOne: [MenuItem] = [
            MenuItem(title: "Initialised with Data Set"),
            MenuItem(title: "Initialised with Data Source"),
            MenuItem(title: "Initialised with Empty Data Source")
        ]
        let sectionTwo = exampleConfigurations

        return [sectionOne, sectionTwo]
    }

    private func createdExampleConfigurations() -> [MenuItem] {
        var section = [MenuItem]()
        section.append(MenuItem(title: "Without Footers", config: configurationWithoutFooter()))
        section.append(MenuItem(title: "Without Search", config: configurationWithoutSearch()))
        section.append(MenuItem(title: "Without floating headers and footers", config: configurationWithoutFloatingHeadersAndFooters()))
        section.append(MenuItem(title: "Without scroll bars", config: configurationWithoutScrollBars()))
        section.append(MenuItem(title: "Alternating colours", config: configurationAlternatingColours()))
        section.append(MenuItem(title: "Fixed/Frozen columns", config: configurationFixedColumns()))
        return section
    }
}

// MARK: - Configuration Examples

extension MenuViewController {
    private func configurationWithoutFooter() -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.shouldShowFooter = false
        return configuration
    }

    private func configurationWithoutSearch() -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.shouldShowSearchSection = false
        return configuration
    }

    private func configurationWithoutFloatingHeadersAndFooters() -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.shouldSectionHeadersFloat = false
        configuration.shouldSectionFootersFloat = false
        return configuration
    }

    private func configurationWithoutScrollBars() -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.shouldShowHorizontalScrollBars = false
        configuration.shouldShowVerticalScrollBars = false
        return configuration
    }

    private func configurationAlternatingColours() -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.highlightedAlternatingRowColors = [
            .init(1, 0.7, 0.7),
            .init(1, 0.7, 0.5),
            .init(1, 1, 0.5),
            .init(0.5, 1, 0.5),
            .init(0.5, 0.7, 1),
            .init(0.5, 0.5, 1),
            .init(1, 0.5, 0.5)
        ]
        configuration.unhighlightedAlternatingRowColors = [
            .init(1, 0.90, 0.90),
            .init(1, 0.90, 0.7),
            .init(1, 1, 0.7),
            .init(0.7, 1, 0.7),
            .init(0.7, 0.9, 1),
            .init(0.7, 0.7, 1),
            .init(1, 0.7, 0.7)
        ]
        return configuration
    }

    private func configurationFixedColumns() -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.fixedColumns = DataTableFixedColumnType(leftColumns: 1, rightColumns: 1)
        return configuration
    }
}

public extension UIColor {
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) {
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
