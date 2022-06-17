//
//  SwiftDataTable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 21/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

public typealias DataTableRow = [DataTableValueType]
public typealias DataTableContent = [DataTableRow]
public typealias DataTableViewModelContent = [[DataCellViewModel]]

public class SwiftDataTable: UIView {
    public enum SupplementaryViewType: String {
        /// Single header positioned at the top above the column section
        case paginationHeader = "SwiftDataTablePaginationHeader"

        /// Column header displayed at the top of each column
        case columnHeader = "SwiftDataTableViewColumnHeader"

        /// Footer displayed at the bottom of each column
        case footerHeader = "SwiftDataTableFooterHeader"

        /// Single header positioned at the bottom below the footer section.
        case searchHeader = "SwiftDataTableSearchHeader"

        init(kind: String) {
            guard let elementKind = SupplementaryViewType(rawValue: kind) else {
                fatalError("Unknown supplementary view type passed in: \(kind)")
            }
            self = elementKind
        }
    }

    public weak var dataSource: SwiftDataTableDataSource?
    public weak var delegate: SwiftDataTableDelegate?

    public var rows: DataTableViewModelContent {
        return currentRowViewModels
    }

    var options: DataTableConfiguration

    // MARK: - Private Properties

    var currentRowViewModels: DataTableViewModelContent {
        get {
            return self.searchRowViewModels
        }
        set {
            self.searchRowViewModels = newValue
        }
    }

    open fileprivate(set) lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchBar.backgroundColor = .systemBackground
            searchBar.barTintColor = .label
        } else {
            searchBar.backgroundColor = .white
            searchBar.barTintColor = .white
        }

        self.addSubview(searchBar)
        return searchBar
    }()

    // Lazy var
    open fileprivate(set) lazy var collectionView: UICollectionView = {
        guard let layout = self.layout else {
            fatalError("The layout needs to be set first")
        }
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = UIColor.systemBackground
        } else {
            collectionView.backgroundColor = UIColor.clear
        }
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        if #available(iOS 10, *) {
            collectionView.isPrefetchingEnabled = false
        }
        self.addSubview(collectionView)
        self.registerCell(collectionView: collectionView)
        return collectionView
    }()

    fileprivate(set) var layout: SwiftDataTableLayout? {
        didSet {
            if let layout = layout {
                collectionView.collectionViewLayout = layout
                collectionView.reloadData()
            }
        }
    }

    fileprivate var dataStructure = DataStructureModel() {
        didSet {
            createDataCellViewModels(with: dataStructure)
        }
    }

    fileprivate(set) var headerViewModels = [DataHeaderFooterViewModel]()
    fileprivate(set) var footerViewModels = [DataHeaderFooterViewModel]()
    fileprivate var rowViewModels = DataTableViewModelContent() {
        didSet {
            searchRowViewModels = rowViewModels
        }
    }

    fileprivate var searchRowViewModels: DataTableViewModelContent!

    fileprivate var paginationViewModel: PaginationHeaderViewModel!
    fileprivate var menuLengthViewModel: MenuLengthHeaderViewModel!
    fileprivate var columnWidths = [CGFloat]()

    //    fileprivate var refreshControl: UIRefreshControl! = {
    //        let refreshControl = UIRefreshControl()
    //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    //        refreshControl.addTarget(self,
    //                                 action: #selector(refreshOptions(sender:)),
    //                                 for: .valueChanged)
    //        return refreshControl
    //    }()

    //    //MARK: - Events
    //    var refreshEvent: (() -> Void)? = nil {
    //        didSet {
    //            if refreshEvent != nil {
    //                self.collectionView.refreshControl = self.refreshControl
    //            }
    //            else {
    //                self.refreshControl = nil
    //                self.collectionView.refreshControl = nil
    //            }
    //        }
    //    }

    //    var showRefreshControl: Bool {
    //        didSet {
    //            if
    //            self.refreshControl
    //        }
    //    }

    // MARK: - Lifecycle

    public init(dataSource: SwiftDataTableDataSource,
                options: DataTableConfiguration? = DataTableConfiguration(),
                frame: CGRect = .zero)
    {
        self.options = options!
        super.init(frame: frame)
        self.dataSource = dataSource

        set(options: options)
        registerObservers()
    }

    public init(data: DataTableContent,
                headerTitles: [String],
                options: DataTableConfiguration = DataTableConfiguration(),
                frame: CGRect = .zero)
    {
        self.options = options
        super.init(frame: frame)
        set(data: data, headerTitles: headerTitles, options: options, shouldReplaceLayout: true)
        registerObservers()
    }

    public convenience init(data: [[String]],
                            headerTitles: [String],
                            options: DataTableConfiguration = DataTableConfiguration(),
                            frame: CGRect = .zero)
    {
        self.init(
            data: data.map { $0.map { .string($0) }},
            headerTitles: headerTitles,
            options: options,
            frame: frame
        )
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let searchBarHeight = heightForSearchView()
        searchBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: searchBarHeight)
        collectionView.frame = CGRect(x: 0, y: searchBarHeight, width: bounds.width, height: bounds.height - searchBarHeight)
    }

    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationWillChange), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }

    @objc func deviceOrientationWillChange() {
        layout?.clearLayoutCache()
    }

    // TODO: Abstract away the registering of classes so that a user can register their own nibs or classes.
    func registerCell(collectionView: UICollectionView) {
        let headerIdentifier = String(describing: DataHeaderFooter.self)
        collectionView.register(DataHeaderFooter.self, forSupplementaryViewOfKind: SupplementaryViewType.columnHeader.rawValue, withReuseIdentifier: headerIdentifier)
        collectionView.register(DataHeaderFooter.self, forSupplementaryViewOfKind: SupplementaryViewType.footerHeader.rawValue, withReuseIdentifier: headerIdentifier)
        collectionView.register(PaginationHeader.self, forSupplementaryViewOfKind: SupplementaryViewType.paginationHeader.rawValue, withReuseIdentifier: String(describing: PaginationHeader.self))
        collectionView.register(MenuLengthHeader.self, forSupplementaryViewOfKind: SupplementaryViewType.searchHeader.rawValue, withReuseIdentifier: String(describing: MenuLengthHeader.self))
        collectionView.register(DataCell.self, forCellWithReuseIdentifier: String(describing: DataCell.self))
    }

    func set(data: DataTableContent, headerTitles: [String], options: DataTableConfiguration? = nil, shouldReplaceLayout: Bool = false) {
        dataStructure = DataStructureModel(data: data, headerTitles: headerTitles, headerFont: options?.fontForHeaders, rowFont: options?.fontForRows)
        createDataCellViewModels(with: dataStructure)
        applyOptions(options)
        if shouldReplaceLayout {
            layout = SwiftDataTableLayout(dataTable: self)
        }
    }

    func applyOptions(_ options: DataTableConfiguration?) {
        guard let options = options else {
            return
        }
        if let defaultOrdering = options.defaultOrdering {
            applyDefaultColumnOrder(defaultOrdering)
        }
    }

    func calculateColumnWidths() {
        // calculate the automatic widths for each column
        columnWidths.removeAll()
        for columnIndex in Array(0 ..< numberOfHeaderColumns()) {
            columnWidths.append(automaticWidthForColumn(index: columnIndex))
        }
        scaleColumnWidthsIfRequired()
    }

    func scaleColumnWidthsIfRequired() {
        guard shouldContentWidthScaleToFillFrame() else {
            return
        }
        scaleToFillColumnWidths()
    }

    func scaleToFillColumnWidths() {
        // if content width is smaller than ipad width
        let totalColumnWidth = columnWidths.reduce(0, +)
        let totalWidth = frame.width
        let gap: CGFloat = totalWidth - totalColumnWidth
        guard totalColumnWidth < totalWidth else {
            return
        }
        // calculate the percentage width presence of each column in relation to the frame width of the collection view
        for columnIndex in Array(0 ..< columnWidths.count) {
            let columnWidth = columnWidths[columnIndex]
            let columnWidthPercentagePresence = columnWidth / totalColumnWidth
            // add result of gap size divided by percentage column width to each column automatic width.
            let gapPortionToDistributeToCurrentColumn = gap * columnWidthPercentagePresence
            // apply final result of each column width to the column width array.
            columnWidths[columnIndex] = columnWidth + gapPortionToDistributeToCurrentColumn
        }
    }

    public func reloadEverything() {
        layout?.clearLayoutCache()
        collectionView.reloadData()
    }

    public func reloadRowsOnly() {}

    public func reload() {
        var data = DataTableContent()
        var headerTitles = [String]()

        let numberOfColumns = dataSource?.numberOfColumns(in: self) ?? 0
        let numberOfRows = dataSource?.numberOfRows(in: self) ?? 0

        for columnIndex in 0 ..< numberOfColumns {
            guard let headerTitle = dataSource?.dataTable(self, headerTitleForColumnAt: columnIndex) else {
                return
            }
            headerTitles.append(headerTitle)
        }

        for index in 0 ..< numberOfRows {
            guard let rowData = dataSource?.dataTable(self, dataForRowAt: index) else {
                return
            }
            data.append(rowData)
        }
        layout?.clearLayoutCache()
        collectionView.resetScrollPositionToTop()
        set(data: data, headerTitles: headerTitles, options: options)
        collectionView.reloadData()
    }

    public func data(for indexPath: IndexPath) -> DataTableValueType {
        return rows[indexPath.section][indexPath.row].data
    }
}

public extension SwiftDataTable {
    func createDataModels(with data: DataStructureModel) {
        dataStructure = data
    }

    func createDataCellViewModels(with dataStructure: DataStructureModel) { // -> DataTableViewModelContent {
        // 1. Create the headers
        headerViewModels = Array(0 ..< (dataStructure.headerTitles.count)).map {
            let headerViewModel = DataHeaderFooterViewModel(
                data: dataStructure.headerTitles[$0],
                sortType: dataStructure.columnHeaderSortType(for: $0),
                dataTable: self
            )
            headerViewModel.configure(dataTable: self, columnIndex: $0)
            return headerViewModel
        }

        footerViewModels = Array(0 ..< (dataStructure.footerTitles.count)).map {
            let sortTypeForFooter = dataStructure.columnFooterSortType(for: $0)
            let headerViewModel = DataHeaderFooterViewModel(
                data: dataStructure.footerTitles[$0],
                sortType: sortTypeForFooter,
                dataTable: self
            )
            return headerViewModel
        }

        // 2. Create the view models
        // let viewModels: DataTableViewModelContent =
        rowViewModels = dataStructure.data.map { currentRowData in
            currentRowData.map {
                DataCellViewModel(data: $0, dataTable: self)
            }
        }
        paginationViewModel = PaginationHeaderViewModel()
        menuLengthViewModel = MenuLengthHeaderViewModel()
        //        self.bindViewToModels()
    }

    //    //MARK: - Events
    //    private func bindViewToModels(){
    //        self.menuLengthViewModel.searchTextFieldDidChangeEvent = { [weak self] text in
    //            self?.searchTextEntryDidChange(text)
    //        }
    //    }
    //
    //    private func searchTextEntryDidChange(_ text: String){
    //        //call delegate function
    //        self.executeSearch(text)
    //    }
}

extension SwiftDataTable: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.numberOfColumns(in: self)
        }
        return dataStructure.columnCount
    }

    public func numberOfSections(in _: UICollectionView) -> Int {
        // if let dataSource = self.dataSource {
        //    return dataSource.numberOfRows(in: self)
        // }
        return numberOfRows()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel: DataCellViewModel
        // if let dataSource = self.dataSource {
        //    cellViewModel = dataSource.dataTable(self, dataForRowAt: indexPath.row)
        // }
        // else {
        cellViewModel = rowModel(at: indexPath)
        // }
        let cell = cellViewModel.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let numberOfItemsInLine: CGFloat = 6

        let inset = UIEdgeInsets.zero

        //        let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let minimumInteritemSpacing: CGFloat = 0
        let contentwidth: CGFloat = minimumInteritemSpacing * (numberOfItemsInLine - 1)
        let itemWidth = (collectionView.frame.width - inset.left - inset.right - contentwidth) / numberOfItemsInLine
        let itemHeight: CGFloat = 100

        return CGSize(width: itemWidth, height: itemHeight)
    }

    public func collectionView(_: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at _: IndexPath) {
        let kind = SupplementaryViewType(kind: elementKind)
        switch kind {
        case .paginationHeader:
            view.backgroundColor = UIColor.darkGray
        default:
            if #available(iOS 13.0, *) {
                view.backgroundColor = .systemBackground
            } else {
                view.backgroundColor = UIColor.white
            }
        }
    }

    public func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cellViewModel = rowModel(at: indexPath)

        if cellViewModel.highlighted {
            cell.contentView.backgroundColor = delegate?.dataTable?(self, highlightedColorForRowIndex: indexPath.item) ?? options.highlightedAlternatingRowColors[indexPath.section % options.highlightedAlternatingRowColors.count]
        } else {
            cell.contentView.backgroundColor = delegate?.dataTable?(self, unhighlightedColorForRowIndex: indexPath.item) ?? options.unhighlightedAlternatingRowColors[indexPath.section % options.unhighlightedAlternatingRowColors.count]
        }
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let elementKind = SupplementaryViewType(kind: kind)
        let viewModel: CollectionViewSupplementaryElementRepresentable
        switch elementKind {
        case .searchHeader: viewModel = menuLengthViewModel
        case .columnHeader: viewModel = headerViewModels[indexPath.index]
        case .footerHeader: viewModel = footerViewModels[indexPath.index]
        case .paginationHeader: viewModel = paginationViewModel
        }
        return viewModel.dequeueView(collectionView: collectionView, viewForSupplementaryElementOfKind: kind, for: indexPath)
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem?(self, indexPath: indexPath)
    }

    public func collectionView(_: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.didDeselectItem?(self, indexPath: indexPath)
    }
}

// MARK: - Swift Data Table Delegate

extension SwiftDataTable {
    func disableScrollViewLeftBounce() -> Bool {
        return true
    }

    func disableScrollViewTopBounce() -> Bool {
        return false
    }

    func disableScrollViewRightBounce() -> Bool {
        return true
    }

    func disableScrollViewBottomBounce() -> Bool {
        return false
    }
}

// MARK: - UICollection View Delegate

extension SwiftDataTable: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }

    public func scrollViewDidScroll(_: UIScrollView) {
        if disableScrollViewLeftBounce() {
            if collectionView.contentOffset.x <= 0 {
                collectionView.contentOffset.x = 0
            }
        }
        if disableScrollViewTopBounce() {
            if collectionView.contentOffset.y <= 0 {
                collectionView.contentOffset.y = 0
            }
        }
        if disableScrollViewRightBounce() {
            let maxX = collectionView.contentSize.width - collectionView.frame.width
            if collectionView.contentOffset.x >= maxX {
                collectionView.contentOffset.x = max(maxX - 1, 0)
            }
        }
        if disableScrollViewBottomBounce() {
            let maxY = collectionView.contentSize.height - collectionView.frame.height
            if collectionView.contentOffset.y >= maxY {
                collectionView.contentOffset.y = maxY - 1
            }
        }
    }
}

// MARK: - Refresh

extension SwiftDataTable {
    //    @objc fileprivate func refreshOptions(sender: UIRefreshControl) {
    //        self.refreshEvent?()
    //    }
    //
    //    func beginRefreshing(){
    //        self.refreshControl.beginRefreshing()
    //    }
    //
    //    func endRefresh(){
    //        self.refreshControl.endRefreshing()
    //    }
}

extension SwiftDataTable {
    private func update() {
        //        print("\nUpdate")
        reloadEverything()
    }

    private func applyDefaultColumnOrder(_ columnOrder: DataTableColumnOrder) {
        highlight(column: columnOrder.index)
        applyColumnOrder(columnOrder)
        sort(column: columnOrder.index, sort: headerViewModels[columnOrder.index].sortType)
    }

    func didTapColumn(index: IndexPath) {
        defer {
            self.update()
        }
        let index = index.index
        toggleSortArrows(column: index)
        highlight(column: index)
        let sortType = headerViewModels[index].sortType
        sort(column: index, sort: sortType)
    }

    func sort(column index: Int, sort by: DataTableSortType) {
        func ascendingOrder(rowOne: [DataCellViewModel], rowTwo: [DataCellViewModel]) -> Bool {
            return rowOne[index].data < rowTwo[index].data
        }
        func descendingOrder(rowOne: [DataCellViewModel], rowTwo: [DataCellViewModel]) -> Bool {
            return rowOne[index].data > rowTwo[index].data
        }

        switch by {
        case .ascending:
            currentRowViewModels = currentRowViewModels.sorted(by: ascendingOrder)
        case .descending:
            currentRowViewModels = currentRowViewModels.sorted(by: descendingOrder)
        default:
            break
        }
    }

    func highlight(column: Int) {
        currentRowViewModels.forEach {
            $0.forEach { $0.highlighted = false }
            $0[column].highlighted = true
        }
    }

    func applyColumnOrder(_ columnOrder: DataTableColumnOrder) {
        Array(0 ..< headerViewModels.count).forEach {
            if columnOrder.index == $0 {
                self.headerViewModels[$0].sortType = columnOrder.order
            } else {
                self.headerViewModels[$0].sortType.toggleToDefault()
            }
        }
    }

    func toggleSortArrows(column: Int) {
        Array(0 ..< headerViewModels.count).forEach {
            if column == $0 {
                self.headerViewModels[$0].sortType.toggle()
            } else {
                self.headerViewModels[$0].sortType.toggleToDefault()
            }
        }
        //        self.headerViewModels.forEach { print($0.sortType) }
    }

    // This is actually mapped to sections
    func numberOfRows() -> Int {
        return currentRowViewModels.count
    }

    func heightForRow(index: Int) -> CGFloat {
        return delegate?.dataTable?(self, heightForRowAt: index) ?? 44
    }

    func rowModel(at indexPath: IndexPath) -> DataCellViewModel {
        return currentRowViewModels[indexPath.section][indexPath.row]
    }

    func numberOfColumns() -> Int {
        return dataStructure.columnCount
    }

    func numberOfHeaderColumns() -> Int {
        return dataStructure.headerTitles.count
    }

    func numberOfFooterColumns() -> Int {
        return dataStructure.footerTitles.count
    }

    func shouldContentWidthScaleToFillFrame() -> Bool {
        return delegate?.shouldContentWidthScaleToFillFrame?(in: self) ?? options.shouldContentWidthScaleToFillFrame
    }

    func shouldSectionHeadersFloat() -> Bool {
        return delegate?.shouldSectionHeadersFloat?(in: self) ?? options.shouldSectionHeadersFloat
    }

    func shouldSectionFootersFloat() -> Bool {
        return delegate?.shouldSectionFootersFloat?(in: self) ?? options.shouldSectionFootersFloat
    }

    func shouldSearchHeaderFloat() -> Bool {
        return delegate?.shouldSearchHeaderFloat?(in: self) ?? options.shouldSearchHeaderFloat
    }

    func shouldShowSearchSection() -> Bool {
        return delegate?.shouldShowSearchSection?(in: self) ?? options.shouldShowSearchSection
    }

    func shouldShowFooterSection() -> Bool {
        return delegate?.shouldShowSearchSection?(in: self) ?? options.shouldShowFooter
    }

    func shouldShowPaginationSection() -> Bool {
        return false
    }

    func shouldSectionFootersShow() -> Bool {
        delegate?.shouldSectionFootersShow?(in: self) ?? options.shouldSectionFootersShow
    }

    func heightForSectionFooter() -> CGFloat {
        if shouldSectionFootersShow() {
            return delegate?.heightForSectionFooter?(in: self) ?? options.heightForSectionFooter
        }
        return 0
    }

    func heightForSectionHeader() -> CGFloat {
        return delegate?.heightForSectionHeader?(in: self) ?? options.heightForSectionHeader
    }

    func widthForColumn(index: Int) -> CGFloat {
        // May need to call calculateColumnWidths.. I want to deprecate it..
        guard let width = delegate?.dataTable?(self, widthForColumnAt: index) else {
            return columnWidths[index]
            // return CGFloat(self.dataStructure.averageDataLengthForColumn(index: index))
        }
        // TODO: Implement it so that the preferred column widths are calculated first, and then the scaling happens after to fill the frame.
//        if width != SwiftDataTableAutomaticColumnWidth {
//            self.columnWidths[index] = width
//        }
        return width
    }

    func heightForSearchView() -> CGFloat {
        guard shouldShowSearchSection() else {
            return 0
        }
        return delegate?.heightForSearchView?(in: self) ?? options.heightForSearchView
    }

    func showVerticalScrollBars() -> Bool {
        return delegate?.shouldShowVerticalScrollBars?(in: self) ?? options.shouldShowVerticalScrollBars
    }

    func showHorizontalScrollBars() -> Bool {
        return delegate?.shouldShowHorizontalScrollBars?(in: self) ?? options.shouldShowHorizontalScrollBars
    }

    func heightOfInterRowSpacing() -> CGFloat {
        return delegate?.heightOfInterRowSpacing?(in: self) ?? options.heightOfInterRowSpacing
    }

    func fontForRows() -> UIFont {
        return delegate?.fontForRows?(in: self) ?? options.fontForRows
    }

    func fontForHeaders() -> UIFont {
        delegate?.fontForHeaders?(in: self) ?? options.fontForHeaders
    }

    func colorForTextInRows() -> UIColor {
        delegate?.colorForTextInRows?(in: self) ?? options.colorForTextInRows
    }

    func colorForLinkTextInRows() -> UIColor {
        delegate?.colorForLinkTextInRows?(in: self) ?? options.colorForLinkTextInRows
    }

    func widthForRowHeader() -> CGFloat {
        return 0
    }

    /// Automatically calcualtes the width the column should be based on the content
    /// in the rows under the column.
    ///
    /// - Parameter index: The column index
    /// - Returns: The automatic width of the column irrespective of the Data Grid frame width
    func automaticWidthForColumn(index: Int) -> CGFloat {
        let columnAverage = CGFloat(dataStructure.averageDataLengthForColumn(index: index))
        let sortingArrowVisualElementWidth: CGFloat = 10 // This is ugly
        let averageDataColumnWidth: CGFloat = columnAverage + sortingArrowVisualElementWidth + (DataCell.Properties.horizontalMargin * 2)
        return max(averageDataColumnWidth, max(minimumColumnWidth(), minimumHeaderColumnWidth(index: index)))
    }

    func calculateContentWidth() -> CGFloat {
        return Array(0 ..< numberOfColumns()).reduce(widthForRowHeader()) { $0 + self.widthForColumn(index: $1) }
    }

    func minimumColumnWidth() -> CGFloat {
        return 70
    }

    func minimumHeaderColumnWidth(index: Int) -> CGFloat {
        return CGFloat(dataStructure.headerTitles[index].widthOfString(usingFont: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)))
    }

    func heightForPaginationView() -> CGFloat {
        guard shouldShowPaginationSection() else {
            return 0
        }
        return 35
    }

    func fixedColumns() -> DataTableFixedColumnType? {
        return delegate?.fixedColumns?(for: self) ?? options.fixedColumns
    }

    func shouldSupportRightToLeftInterfaceDirection() -> Bool {
        return delegate?.shouldSupportRightToLeftInterfaceDirection?(in: self) ?? options.shouldSupportRightToLeftInterfaceDirection
    }
}

// MARK: - Search Bar Delegate

extension SwiftDataTable: UISearchBarDelegate {
    public func searchBar(_: UISearchBar, textDidChange searchText: String) {
        executeSearch(searchText)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    // TODO: Use Regular expression isntead
    private func filteredResults(with needle: String, on originalArray: DataTableViewModelContent) -> DataTableViewModelContent {
        var filteredSet = DataTableViewModelContent()
        let needle = needle.lowercased()
        Array(0 ..< originalArray.count).forEach {
            let row = originalArray[$0]
            // Add some sort of index array so we use that to iterate through the columns
            // The idnex array will be defined by the column definition inside the configuration object provided by the user
            // Index array might look like this [1, 3, 4]. Which means only those columns should be searched into
            for item in row {
                let stringData: String = item.data.stringRepresentation.lowercased()
                if stringData.lowercased().range(of: needle) != nil {
                    filteredSet.append(row)
                    // Stop searching through the rest of the columns in the same row and break
                    break
                }
            }
        }

        return filteredSet
    }

    fileprivate func executeSearch(_ needle: String) {
        let oldFilteredRowViewModels = searchRowViewModels!

        if needle.isEmpty {
            // DONT DELETE ORIGINAL CACHE FOR LAYOUTATTRIBUTES
            // MAYBE KEEP TWO COPIES.. ONE FOR SEARCH AND ONE FOR DEFAULT
            searchRowViewModels = rowViewModels
        } else {
            searchRowViewModels = filteredResults(with: needle, on: rowViewModels)
            //            print("needle: \(needle), rows found: \(self.searchRowViewModels!.count)")
        }
        layout?.clearLayoutCache()
        //        self.collectionView.scrollToItem(at: IndexPath(0), at: UICollectionViewScrollPosition.top, animated: false)
        // So the header view doesn't flash when user is at the bottom of the collectionview and a search result is returned that doesn't feel the screen.
        collectionView.resetScrollPositionToTop()
        differenceSorter(oldRows: oldFilteredRowViewModels, filteredRows: searchRowViewModels)
    }

    private func differenceSorter(
        oldRows: DataTableViewModelContent,
        filteredRows: DataTableViewModelContent,
        animations: Bool = false,
        completion: ((Bool) -> Void)? = nil
    ) {
        if animations == false {
            UIView.setAnimationsEnabled(false)
        }
        collectionView.performBatchUpdates({
            // finding the differences

            // The currently displayed rows - in this case named old rows - is scanned over.. deleting any entries that are not existing in the newly created filtered list.
            for (oldIndex, oldRowViewModel) in oldRows.enumerated() {
                let index = self.searchRowViewModels.firstIndex { rowViewModel in
                    oldRowViewModel == rowViewModel
                }
                if index == nil {
                    self.collectionView.deleteSections([oldIndex])
                }
            }

            // Iterates over the new search results and compares them with the current result set displayed - in this case name old - inserting any entries that are not existant in the currently displayed result set
            for (currentIndex, currentRolwViewModel) in filteredRows.enumerated() {
                let oldIndex = oldRows.firstIndex { oldRowViewModel in
                    currentRolwViewModel == oldRowViewModel
                }
                if oldIndex == nil {
                    self.collectionView.insertSections([currentIndex])
                }
            }
        }, completion: { finished in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            if animations == false {
                UIView.setAnimationsEnabled(true)
            }
            completion?(finished)
        })
    }
}

extension SwiftDataTable {
    func set(options _: DataTableConfiguration? = nil) {
        layout = SwiftDataTableLayout(dataTable: self)
        rowViewModels = DataTableViewModelContent()
        paginationViewModel = PaginationHeaderViewModel()
        menuLengthViewModel = MenuLengthHeaderViewModel()
        // self.reload();
    }
}
