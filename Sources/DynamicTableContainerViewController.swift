//
//  DynamicTableContainerViewController.swift
//  SCMBImages
//
//  Created by Razmig Sarkissian on 16/03/2016.
//  Copyright © 2016 Azurgate. All rights reserved.
//

import UIKit

open class DynamicTableContainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak open var tableView : UITableView!
    
    // Cell sizing cache
    open var useCellSizingCache=false
    fileprivate var _sizingCellCache:[String:Configurable]=[:] // IOS7 Only
    fileprivate var _sizesCellCache:[Int:CGFloat]=[:]
    
    // Cell cache
    open var useCellCache=false
    fileprivate var _cellCache:[Int:UITableViewCell]=[:]
    fileprivate var _cellInCacheHasBeenConfigured:[Int:Bool]=[:]
    
    //Supplementary view distinction
    enum Supplementary:Int{
        case header
        case footer
    }
    
    // Registration Flags
    fileprivate var _nibOrClasseHasBeenRegistredForCellIdentifier:[String:Bool]=[:]
    fileprivate var _nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier:[String:Bool]=[:]
    
    // Delegates
    var cellsDelegate:DynamicIdentifiableCells?
    var headerDelegate:DynamicIdentifiableHeaders?
    var footerDelegate:DynamicIdentifiableFooters?
    
    //MARK: - Initializers
    
    //    override init(style: UITableViewStyle) {
    //        super.init(style:style);
    //        self._configureDelegate()
    //    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!){
        super.init(nibName: nibNameOrNil,bundle:nibBundleOrNil);
        self._configureDelegate()
    }
    
    required public init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        self._configureDelegate()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.purgeCaches()
    }
    
    // Delegation configuration
    
    func _configureDelegate(){
        self.cellsDelegate=self as? DynamicIdentifiableCells
        self.headerDelegate=self as? DynamicIdentifiableHeaders
        self.footerDelegate=self as? DynamicIdentifiableFooters
    }
    
    
    
    func validate()->(isValid:Bool,details:[(result:Bool, message:String)]){
        var result:(isValid:Bool,details:[(result:Bool, message:String)])=(isValid:true,details:[])
        // Let's iterate on each cell
        let nbOfSections=self.tableView.numberOfSections
        for section in 0..<nbOfSections {
            let nbOfRow=self.tableView.numberOfRows(inSection: section)
            for row in 0..<nbOfRow{
                let indexPath = IndexPath(row: row, section: section)
                if let cell = self.tableView.cellForRow(at: indexPath) as? Validable{
                    let cellResultTuple = cell.validate() // (result:Bool,message:String?)
                    result.isValid = result.isValid&&cellResultTuple.result
                    result.details.append(cellResultTuple)
                }
            }
        }
        return result
    }
    
    override open  func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.purgeSizeRelatedCaches()
    }
    
    
    //MARK: - Caches management
    
    open func purgeCaches(){
        if(useCellCache){
            self._cellCache=[:]
            self._nibOrClasseHasBeenRegistredForCellIdentifier=[:]
            self._nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier=[:]
            self.purgeSizeRelatedCaches()
        }
    }
    
    open func purgeSizeRelatedCaches(){
        if(useCellSizingCache){
            self._sizingCellCache=[:]
            self._sizesCellCache=[:]
            self._cellInCacheHasBeenConfigured=[:]
        }
    }
    
    //MARK: - UITableViewDataSource
    
    // We have decided to make this UITableViewDataSource final to force the dynamic pattern
    open func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let indexToPath=self.indexPathToindex(indexPath)
        if self.useCellCache {
            if let cell=self._cellCache[indexToPath]{
                if let _=_cellInCacheHasBeenConfigured[indexToPath] {
                    return cell
                }else{
                    let cell = self._configuredCellForIndexPath(indexPath)
                    _cellInCacheHasBeenConfigured[indexToPath]=true
                    _cellCache[indexToPath]=cell
                    return cell
                }
            }
        }
        return self._configuredCellForIndexPath(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.useCellSizingCache {
            if let height=_sizesCellCache[self.indexPathToindex(indexPath)]{
                return height
            }
        }
        
        if let reuseIdentifier = self.cellsDelegate?.cellReuseIdentifierForIndexPath(indexPath){
            let cell = self._cellForReuseIdentifier(reuseIdentifier)
            if  let computedHeightCell = cell as? ComputedHeightView{
                if let dataSource=self.cellsDelegate!.cellDataSourceForIndexPath(indexPath) {
                    let height=computedHeightCell.heightFor(dataSource, constrainedToWidth: self.tableView.bounds.width)
                    if self.useCellSizingCache {
                        _sizesCellCache[self.indexPathToindex(indexPath)]=height
                    }
                    return height
                }else{
                    return 0
                }
            }
            
            if (!D.iOS7 ) {
                return UITableView.automaticDimension;
            }
            
            // IOS7 only
            // USE Autolayout based heights
            // Make sure the constraints have been added to this cell
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            
            if let dataSource=self.cellsDelegate!.cellDataSourceForIndexPath(indexPath) {
                if let configurable = cell as? Configurable{
                    if let configurator=dataSource as? Configurator {
                        configurable.configureWith(configurator)
                    }
                }
            }
            
            cell.bounds = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: cell.bounds.height)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            var height = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            height += 1.0;
            if self.useCellSizingCache {
                _sizesCellCache[self.indexPathToindex(indexPath)]=height
            }
            return height;
        }
        
        // We have failed
        if self.useCellSizingCache {
            _sizesCellCache[self.indexPathToindex(indexPath)]=tableView.rowHeight
        }
        
        return tableView.rowHeight
    }
    
    
    // Returns a Configured Cell or an Error cell message.
    func _configuredCellForIndexPath(_ indexPath:IndexPath)->UITableViewCell{
        if self.cellsDelegate != nil  {
            if let reuseIdentifier = self.cellsDelegate?.cellReuseIdentifierForIndexPath(indexPath){
                let cell=self._cellForIndexPath(indexPath, withReuseIdentifier: reuseIdentifier)
                if cell is ErrorUITableViewCell{
                    return cell
                }
                if cell is Configurable {
                    if let dataSource=self.cellsDelegate!.cellDataSourceForIndexPath(indexPath) {
                        if let configurator=dataSource as? Configurator {
                            (cell as! Configurable).configureWith(configurator)
                        }
                        return cell
                    }else{
                        let errMessage="\(reuseIdentifier) Invalid data sources"
                        return self._errorCellWithMessage(errMessage, cellReuseIdentifier:reuseIdentifier)
                    }
                }else{
                    let errMessage="\(reuseIdentifier) \(NSStringFromClass(type(of: cell))) should conform to Configurable Protocol"
                    return self._errorCellWithMessage(errMessage, cellReuseIdentifier:reuseIdentifier)
                }
            }
            let errMessage="Cell is not configured"
            return self._errorCellWithMessage(errMessage, cellReuseIdentifier:"")
        }else{
            let errMessage="Cell's Delegate is not valid"
            return self._errorCellWithMessage(errMessage, cellReuseIdentifier:"")
        }
    }
    
    
    fileprivate func _cacheCellForSizingIfNecessary(_ cell:Configurable, forIndexPath indexPath:IndexPath){
        //let idx=self.indexPathToindex(indexPath)
        
    }
    
    fileprivate func _cacheCellIfNecessary(_ cell:Configurable, forIndexPath indexPath:IndexPath){
        //let idx=self.indexPathToindex(indexPath)
    }
    
    
    // Cantor pairing function
    
    func indexPathToindex(_ indexPath: IndexPath)->Int{
        let a = (indexPath as NSIndexPath).section+1
        let b = (indexPath as NSIndexPath).row+1
        return (a + b) * (a + b + 1) / 2 + a
    }
    
    
    func _cellForReuseIdentifier(_ reuseIdentifier:String)->UITableViewCell{
        return self._cellForIndexPath(nil, withReuseIdentifier:reuseIdentifier)
    }
    
    func _cellForIndexPath(_ indexPath:IndexPath?, withReuseIdentifier reuseIdentifier:String)->UITableViewCell{
        self._registerCellNibOrClasseIfNecessaryFor(reuseIdentifier)
        // Dequeue the cell
        if indexPath != nil {
            let cell:AnyObject = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath!)
            return cell as! UITableViewCell
        }else{
            // Cell sizing
            if let cell:AnyObject = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier){
                return cell as! UITableViewCell
            }
        }
        let errMessage="Cell configuration error section:\((indexPath as NSIndexPath?)?.section) row:\((indexPath as NSIndexPath?)?.row) reuseIdentifier\(reuseIdentifier)"
        return self._errorCellWithMessage(errMessage, cellReuseIdentifier:reuseIdentifier)
    }
    
    
    func _errorCellWithMessage(_ message:String, cellReuseIdentifier reuseIdentifier:String)->ErrorUITableViewCell{
        let errorTableViewCell = ErrorUITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        errorTableViewCell.textLabel!.text = message
        errorTableViewCell.textLabel?.numberOfLines=0
        return errorTableViewCell
    }
    
    
    func _registerCellNibOrClasseIfNecessaryFor(_ reuseIdentifier:String){
        if let _ = _nibOrClasseHasBeenRegistredForCellIdentifier[reuseIdentifier] {
        }else{
            if (self as? DynamicCellsByClass != nil) {
                if let dynClassSelf = self as? DynamicCellsByClass{
                    if let cellClass:AnyClass = dynClassSelf.cellClassForReuseIdentifier(reuseIdentifier){
                        self.tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
                        _nibOrClasseHasBeenRegistredForCellIdentifier[reuseIdentifier]=true
                    }
                }
            }
            if (self as? DynamicCellsByNibs != nil) {
                if let dynNibSelf = self as? DynamicCellsByNibs{
                    if let nib:UINib = dynNibSelf.cellNibForReuseIdentifier(reuseIdentifier){
                        self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
                        _nibOrClasseHasBeenRegistredForCellIdentifier[reuseIdentifier]=true
                    }
                }
            }
        }
    }
    
    
    // MARK: Header and Footers views
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let delegate=self.headerDelegate{
            if let reuseIdentifier=delegate.headerReuseIdentifierForSection(section) {
                return self._configuredSupplementaryView(Supplementary.header,forReuseIdentifier: reuseIdentifier)
            }
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let delegate=self.footerDelegate{
            if let reuseIdentifier=delegate.footerReuseIdentifierForSection(section) {
                return self._configuredSupplementaryView(Supplementary.footer,forReuseIdentifier:reuseIdentifier)
            }
        }
        return nil
    }
    
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let delegate=self.headerDelegate{
            if let reuseIdentifier=delegate.headerReuseIdentifierForSection(section) {
                if let dataSource=delegate.headerDataSourceForReuseIdentifier(reuseIdentifier) {
                    return delegate.headerHeightFor(dataSource, constrainedToWidth: self.view.frame.width,section:section)
                }
            }
        }
        return 0.0
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let delegate=self.footerDelegate{
            if let reuseIdentifier=delegate.footerReuseIdentifierForSection(section) {
                if let dataSource=delegate.footerDataSourceForReuseIdentifier(reuseIdentifier) {
                    return delegate.footerHeightFor(dataSource, constrainedToWidth: self.view.frame.width ,section:section)
                }
            }
        }
        return 0.0
    }
    
    
    fileprivate func _configuredSupplementaryView(_ nature:Supplementary, forReuseIdentifier reuseIdentifier:String)->UIView?{
        var view:UIView?
        var dataSource:DynamicDataSource?
        if nature == Supplementary.header{
            view=self._headerFooterViewForReuseIdentifer(reuseIdentifier)
            if let delegate=self.headerDelegate{
                dataSource=delegate.headerDataSourceForReuseIdentifier(reuseIdentifier)
            }
        }else{
            view=self._headerFooterViewForReuseIdentifer(reuseIdentifier)
            if let delegate=self.footerDelegate{
                dataSource=delegate.footerDataSourceForReuseIdentifier(reuseIdentifier)
            }
        }
        if view != nil && dataSource != nil {
            if let configurableView=view as? Configurable {
                if let configurator = dataSource as? Configurator{
                    configurableView.configureWith(configurator)
                }
            }
        }
        return view
    }
    
    
    func _headerFooterViewForReuseIdentifer(_ reuseIdentifier:String)->UIView?{
        if let view = self._registerOrInstantiateNibOrClasseIfNecessaryForHeaderOrFooter(reuseIdentifier){
            return view
        }
        if let header: AnyObject = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier){
            if header is UIView {
                return header as? UIView
            }
        }
        return nil
    }
    
    
    func _registerOrInstantiateNibOrClasseIfNecessaryForHeaderOrFooter(_ reuseIdentifier:String)->UIView?{
        if let _ = _nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier[reuseIdentifier] {
            return nil
        }else{
            if (self as? DynamicHeaderFooterByClass != nil) {
                if let dynClassSelf = self as? DynamicHeaderFooterByClass{
                    if let cellClass:AnyClass = dynClassSelf.headerFooterClassForReuseIdentifier(reuseIdentifier){
                        // Views musts be registred for dequeue
                        self.tableView.register(cellClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
                        _nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier[reuseIdentifier]=true
                        return nil
                    }
                }
            }
            if (self as? DynamicHeaderFooterByNib != nil) {
                if let dynNibSelf = self as? DynamicHeaderFooterByNib{
                    if let nib:UINib = dynNibSelf.headerFooterNibForReuseIdentifier(reuseIdentifier){
                        // Views musts be registred for dequeue
                        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
                        _nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier[reuseIdentifier]=true
                        return nil
                    }
                }
            }
        }
        return nil
    }
    
    open func indexPathIsTheLastOfTheSection(_ indexPath:IndexPath)->Bool{
        let c=self.tableView(self.tableView, numberOfRowsInSection: (indexPath as NSIndexPath).section)
        return ((indexPath as NSIndexPath).row == c-1)
    }
    
    open func scrollToTheTop(_ animated:Bool){
        DispatchQueue.main.async { () -> Void in
            self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: animated)
        }
    }
    
}
