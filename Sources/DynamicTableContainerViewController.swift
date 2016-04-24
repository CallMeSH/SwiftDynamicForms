//
//  DynamicTableContainerViewController.swift
//  SCMBImages
//
//  Created by Razmig Sarkissian on 16/03/2016.
//  Copyright © 2016 Azurgate. All rights reserved.
//

import UIKit

class DynamicTableContainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView : UITableView!
    
    // Cell sizing cache
    var useCellSizingCache=false
    private var _sizingCellCache:[String:Configurable]=[:] // IOS7 Only
    private var _sizesCellCache:[Int:CGFloat]=[:]
    
    // Cell cache
    var useCellCache=false
    private var _cellCache:[Int:UITableViewCell]=[:]
    private var _cellInCacheHasBeenConfigured:[Int:Bool]=[:]
    
    //Supplementary view distinction
    enum Supplementary:Int{
        case HEADER
        case FOOTER
    }
    
    // Registration Flags
    private var _nibOrClasseHasBeenRegistredForCellIdentifier:[String:Bool]=[:]
    private var _nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier:[String:Bool]=[:]
    
    // Delegates
    var cellsDelegate:DynamicIdentifiableCells?
    var headerDelegate:DynamicIdentifiableHeaders?
    var footerDelegate:DynamicIdentifiableFooters?
    
    //MARK: - Initializers
    
//    override init(style: UITableViewStyle) {
//        super.init(style:style);
//        self._configureDelegate()
//    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!){
        super.init(nibName: nibNameOrNil,bundle:nibBundleOrNil);
        self._configureDelegate()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        self._configureDelegate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.purgeCaches()
    }
    
    // Delegation configuration
    
    private func _configureDelegate(){
        self.cellsDelegate=self as? DynamicIdentifiableCells
        self.headerDelegate=self as? DynamicIdentifiableHeaders
        self.footerDelegate=self as? DynamicIdentifiableFooters
    }
    
    
    
    func validate()->(isValid:Bool,details:[(result:Bool, message:String)]){
        var result:(isValid:Bool,details:[(result:Bool, message:String)])=(isValid:true,details:[])
        // Let's iterate on each cell
        let nbOfSections=self.tableView.numberOfSections
        for section in 0..<nbOfSections {
            let nbOfRow=self.tableView.numberOfRowsInSection(section)
            for row in 0..<nbOfRow{
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? Validable{
                    let cellResultTuple = cell.validate() // (result:Bool,message:String?)
                    result.isValid = result.isValid&&cellResultTuple.result
                    result.details.append(cellResultTuple)
                }
            }
        }
        return result
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.purgeSizeRelatedCaches()
    }
    
    
    //MARK: - Caches management
    
    func purgeCaches(){
        if(useCellCache){
            self._cellCache=[:]
            self._nibOrClasseHasBeenRegistredForCellIdentifier=[:]
            self._nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier=[:]
            self.purgeSizeRelatedCaches()
        }
    }
    
    func purgeSizeRelatedCaches(){
        if(useCellSizingCache){
            self._sizingCellCache=[:]
            self._sizesCellCache=[:]
            self._cellInCacheHasBeenConfigured=[:]
        }
    }
    
    //MARK: - UITableViewDataSource
    
    // We have decided to make this UITableViewDataSource final to force the dynamic pattern
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
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
                return UITableViewAutomaticDimension;
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
            
            cell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds))
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            var height = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
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
    private func _configuredCellForIndexPath(indexPath:NSIndexPath)->UITableViewCell{
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
                    let errMessage="\(reuseIdentifier) \(NSStringFromClass(cell.dynamicType)) should conform to Configurable Protocol"
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
    
    
    private func _cacheCellForSizingIfNecessary(cell:Configurable, forIndexPath indexPath:NSIndexPath){
        //let idx=self.indexPathToindex(indexPath)
        
    }
    
    private func _cacheCellIfNecessary(cell:Configurable, forIndexPath indexPath:NSIndexPath){
        //let idx=self.indexPathToindex(indexPath)
    }
    
    
    // Cantor pairing function
    
    func indexPathToindex(indexPath: NSIndexPath)->Int{
        let a = indexPath.section+1
        let b = indexPath.row+1
        return (a + b) * (a + b + 1) / 2 + a
    }
    
    
    private func _cellForReuseIdentifier(reuseIdentifier:String)->UITableViewCell{
        return self._cellForIndexPath(nil, withReuseIdentifier:reuseIdentifier)
    }
    
    private func _cellForIndexPath(indexPath:NSIndexPath?, withReuseIdentifier reuseIdentifier:String)->UITableViewCell{
        self._registerCellNibOrClasseIfNecessaryFor(reuseIdentifier)
        // Dequeue the cell
        if indexPath != nil {
            let cell:AnyObject = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath!)
            return cell as! UITableViewCell
        }else{
            // Cell sizing
            if let cell:AnyObject = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier){
                return cell as! UITableViewCell
            }
        }
        let errMessage="Cell configuration error section:\(indexPath?.section) row:\(indexPath?.row) reuseIdentifier\(reuseIdentifier)"
        return self._errorCellWithMessage(errMessage, cellReuseIdentifier:reuseIdentifier)
    }
    
    
    private func _errorCellWithMessage(message:String, cellReuseIdentifier reuseIdentifier:String)->ErrorUITableViewCell{
        let errorTableViewCell = ErrorUITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        errorTableViewCell.textLabel!.text = message
        errorTableViewCell.textLabel?.numberOfLines=0
        return errorTableViewCell
    }
    
    
    private func _registerCellNibOrClasseIfNecessaryFor(reuseIdentifier:String){
        if let _ = _nibOrClasseHasBeenRegistredForCellIdentifier[reuseIdentifier] {
        }else{
            if (self as? DynamicCellsByClass != nil) {
                if let dynClassSelf = self as? DynamicCellsByClass{
                    if let cellClass:AnyClass = dynClassSelf.cellClassForReuseIdentifier(reuseIdentifier){
                        self.tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)
                        _nibOrClasseHasBeenRegistredForCellIdentifier[reuseIdentifier]=true
                    }
                }
            }
            if (self as? DynamicCellsByNibs != nil) {
                if let dynNibSelf = self as? DynamicCellsByNibs{
                    if let nib:UINib = dynNibSelf.cellNibForReuseIdentifier(reuseIdentifier){
                        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
                        _nibOrClasseHasBeenRegistredForCellIdentifier[reuseIdentifier]=true
                    }
                }
            }
        }
    }
    
    
    // MARK: Header and Footers views
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let delegate=self.headerDelegate{
            if let reuseIdentifier=delegate.headerReuseIdentifierForSection(section) {
                return self._configuredSupplementaryView(Supplementary.HEADER,forReuseIdentifier: reuseIdentifier)
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let delegate=self.footerDelegate{
            if let reuseIdentifier=delegate.footerReuseIdentifierForSection(section) {
                return self._configuredSupplementaryView(Supplementary.FOOTER,forReuseIdentifier:reuseIdentifier)
            }
        }
        return nil
    }
    
    
    func  tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let delegate=self.headerDelegate{
            if let reuseIdentifier=delegate.headerReuseIdentifierForSection(section) {
                if let dataSource=delegate.headerDataSourceForReuseIdentifier(reuseIdentifier) {
                    return delegate.headerHeightFor(dataSource, constrainedToWidth: self.view.frame.width,section:section)
                }
            }
        }
        return 0.0
    }
    
    func  tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let delegate=self.footerDelegate{
            if let reuseIdentifier=delegate.footerReuseIdentifierForSection(section) {
                if let dataSource=delegate.footerDataSourceForReuseIdentifier(reuseIdentifier) {
                    return delegate.footerHeightFor(dataSource, constrainedToWidth: self.view.frame.width ,section:section)
                }
            }
        }
        return 0.0
    }
    
    
    private func _configuredSupplementaryView(nature:Supplementary, forReuseIdentifier reuseIdentifier:String)->UIView?{
        var view:UIView?
        var dataSource:DynamicDataSource?
        if nature == Supplementary.HEADER{
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
    
    
    private func _headerFooterViewForReuseIdentifer(reuseIdentifier:String)->UIView?{
        if let view = self._registerOrInstantiateNibOrClasseIfNecessaryForHeaderOrFooter(reuseIdentifier){
            return view
        }
        if let header: AnyObject = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseIdentifier){
            if header is UIView {
                return header as? UIView
            }
        }
        return nil
    }
    
    
    private func _registerOrInstantiateNibOrClasseIfNecessaryForHeaderOrFooter(reuseIdentifier:String)->UIView?{
        if let _ = _nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier[reuseIdentifier] {
            return nil
        }else{
            if (self as? DynamicHeaderFooterByClass != nil) {
                if let dynClassSelf = self as? DynamicHeaderFooterByClass{
                    if let cellClass:AnyClass = dynClassSelf.headerFooterClassForReuseIdentifier(reuseIdentifier){
                        // Views musts be registred for dequeue
                        self.tableView.registerClass(cellClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
                        _nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier[reuseIdentifier]=true
                        return nil
                    }
                }
            }
            if (self as? DynamicHeaderFooterByNib != nil) {
                if let dynNibSelf = self as? DynamicHeaderFooterByNib{
                    if let nib:UINib = dynNibSelf.headerFooterNibForReuseIdentifier(reuseIdentifier){
                        // Views musts be registred for dequeue
                        self.tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
                        _nibOrClasseHasBeenRegistredForHeaderOrFooterIdentifier[reuseIdentifier]=true
                        return nil
                    }
                }
            }
        }
        return nil
    }
    
    func indexPathIsTheLastOfTheSection(indexPath:NSIndexPath)->Bool{
        let c=self.tableView(self.tableView, numberOfRowsInSection: indexPath.section)
        return (indexPath.row == c-1)
    }
    
    func scrollToTheTop(animated:Bool){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: animated)
        }
    }
    
}