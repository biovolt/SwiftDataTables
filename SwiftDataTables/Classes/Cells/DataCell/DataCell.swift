//
//  DataCell.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

class DataCell: UICollectionViewCell {
    // MARK: - Properties

    public enum Properties {
        static let verticalMargin: CGFloat = 5
        static let horizontalMargin: CGFloat = 15
        static let widthConstant: CGFloat = 20
    }

    let dataLabel = UILabel()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dataLabel)
        NSLayoutConstraint.activate([
            dataLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Properties.widthConstant),
            dataLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Properties.verticalMargin),
            dataLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Properties.verticalMargin),
            dataLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Properties.horizontalMargin),
            dataLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Properties.horizontalMargin)
        ])
    }

    func configure(_ viewModel: DataCellViewModel, dataTable: SwiftDataTable) {
        dataLabel.text = viewModel.data.stringRepresentation

//        self.contentView.backgroundColor = .white
        if viewModel.data.hasSameCaseAs(.stringLink("")) {
            dataLabel.textColor = dataTable.colorForLinkTextInRows()
        } else {
            dataLabel.textColor = dataTable.colorForTextInRows()
        }
        dataLabel.font = dataTable.fontForRows()
    }
}
