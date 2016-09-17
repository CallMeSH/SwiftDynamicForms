//
//  DynamicForms.swift
//  DynamicForms
//
//  Created by Benoit Pereira da Silva on 21/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.
//


import Foundation

// MARK: DataSources

public protocol Validator{
    associatedtype T
    func validateValue(_: T)->(result:Bool,message:String)
}

// Informal protocol
public protocol DynamicDataSource{
}

open class Configurator:DynamicDataSource{
    public init(){
    }
}

public protocol Configurable{
    func configureWith(_ configurator:Configurator)
}

public protocol ComputedHeightView:Configurable{
    func heightFor(_ dataSource:DynamicDataSource, constrainedToWidth width:CGFloat)->CGFloat
}

public protocol Validable{
    func validate()->(result:Bool,message:String)
}

//MARK: Delegation for cell management

public protocol DynamicIdentifiableCells{
    func cellReuseIdentifierForIndexPath(_ indexPath:IndexPath)->String?
    func cellDataSourceForIndexPath(_ indexPath:IndexPath)->DynamicDataSource?
}

public protocol DynamicCellsByClass{
    func cellClassForReuseIdentifier(_ reuseIdentifier:String)->AnyClass?
}

// MARK: Delegation for Supplementary views

public protocol DynamicHeadersAndFooters:DynamicIdentifiableHeaders,DynamicIdentifiableFooters{
}

public protocol DynamicIdentifiableHeaders{
    func headerReuseIdentifierForSection(_ section:Int)->String?
    func headerDataSourceForReuseIdentifier(_ reuseIdentifier:String)->DynamicDataSource?
    func headerHeightFor(_ dataSource:DynamicDataSource, constrainedToWidth width:CGFloat, section:Int)->CGFloat
}

public protocol DynamicIdentifiableFooters{
    func footerReuseIdentifierForSection(_ section:Int)->String?
    func footerDataSourceForReuseIdentifier(_ reuseIdentifier:String)->DynamicDataSource?
    func footerHeightFor(_ dataSource:DynamicDataSource, constrainedToWidth width:CGFloat, section:Int)->CGFloat
}

public protocol DynamicHeaderFooterByClass{// A UITableViewHeaderFooterView subclass on IOS
    func headerFooterClassForReuseIdentifier(_ reuseIdentifier:String)->AnyClass?
}
