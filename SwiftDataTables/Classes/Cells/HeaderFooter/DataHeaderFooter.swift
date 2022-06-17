//
//  DataHeaderFooter.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

class DataHeaderFooter: UICollectionReusableView {

    //MARK: - Properties
    private enum Properties {
        static let labelHorizontalMargin: CGFloat = 15
        static let labelVerticalMargin: CGFloat = 5
        static let separator: CGFloat = 5
        static let imageViewHorizontalMargin: CGFloat = 5
        static let labelWidthConstant: CGFloat = 20
        static let imageViewWidthConstant: CGFloat = 20
        static let imageViewAspectRatio: CGFloat = 0.75
        static let labelBottomSeparator: CGFloat = 0.75

        
    }
    let titleLabel = UILabel()
    let sortingImageView = UIImageView()
    let bottomLine = UIView()


    //MARK: - Events
    var didTapEvent: (() -> Void)? = nil

    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .heavy)
        addSubview(titleLabel)
        addSubview(sortingImageView)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(DataHeaderFooter.didTapView))
        addGestureRecognizer(tapGesture)
        bottomLine.backgroundColor = UIColor.black
        bottomLine.tintColor = UIColor.black
        bottomLine.isHidden = false
        addSubview(bottomLine)
    }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sortingImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Properties.labelWidthConstant),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Properties.labelVerticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Properties.labelHorizontalMargin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Properties.labelVerticalMargin),
            sortingImageView.widthAnchor.constraint(equalToConstant: Properties.imageViewWidthConstant),
            sortingImageView.widthAnchor.constraint(equalTo: sortingImageView.heightAnchor, multiplier: Properties.imageViewAspectRatio),
            sortingImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            sortingImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Properties.imageViewHorizontalMargin),
            sortingImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Properties.separator),
            bottomLine.heightAnchor.constraint(equalToConstant: Properties.labelBottomSeparator),
            bottomLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            bottomLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            bottomLine.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
    }
    
    func configure(viewModel: DataHeaderFooterViewModel, dataTable: SwiftDataTable) {
        self.titleLabel.text = viewModel.data
        self.titleLabel.font = dataTable.fontForHeaders()
        self.sortingImageView.image = viewModel.imageForSortingElement
        self.sortingImageView.tintColor = viewModel.tintColorForSortingElement
        self.backgroundColor = .white
    }
    @objc func didTapView(){
        self.didTapEvent?()
    }
}
