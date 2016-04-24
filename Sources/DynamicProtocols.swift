//
//  DynamicForms.swift
//  DynamicForms
//
//  Created by Benoit Pereira da Silva on 21/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.
//


import Foundation

// MARK: DataSources

protocol Validator{
    typealias T
    func validateValue(_: T)->(result:Bool,message:String)
}

// Informal protocol
protocol DynamicDataSource{
}

public class Configurator:DynamicDataSource{
}

protocol Configurable{
    func configureWith(configurator:Configurator)
}

protocol ComputedHeightView:Configurable{
    func heightFor(dataSource:DynamicDataSource, constrainedToWidth width:CGFloat)->CGFloat
}

protocol Validable{
    func validate()->(result:Bool,message:String)
}

//MARK: Delegation for cell management

protocol DynamicIdentifiableCells{
    func cellReuseIdentifierForIndexPath(indexPath:NSIndexPath)->String?
    func cellDataSourceForIndexPath(indexPath:NSIndexPath)->DynamicDataSource?
}

protocol DynamicCellsByClass{
    func cellClassForReuseIdentifier(reuseIdentifier:String)->AnyClass?
}

// MARK: Delegation for Supplementary views

protocol DynamicHeadersAndFooters:DynamicIdentifiableHeaders,DynamicIdentifiableFooters{
}

protocol DynamicIdentifiableHeaders{
    func headerReuseIdentifierForSection(section:Int)->String?
    func headerDataSourceForReuseIdentifier(reuseIdentifier:String)->DynamicDataSource?
    func headerHeightFor(dataSource:DynamicDataSource, constrainedToWidth width:CGFloat, section:Int)->CGFloat
}

protocol DynamicIdentifiableFooters{
    func footerReuseIdentifierForSection(section:Int)->String?
    func footerDataSourceForReuseIdentifier(reuseIdentifier:String)->DynamicDataSource?
    func footerHeightFor(dataSource:DynamicDataSource, constrainedToWidth width:CGFloat, section:Int)->CGFloat
}

protocol DynamicHeaderFooterByClass{// A UITableViewHeaderFooterView subclass on IOS
    func headerFooterClassForReuseIdentifier(reuseIdentifier:String)->AnyClass?
}