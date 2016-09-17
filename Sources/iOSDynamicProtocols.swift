//
//  DynamicForms.swift
//  DynamicForms
//
//  Created by Benoit Pereira da Silva on 21/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.
//


import UIKit

open class CellConfigurator:Configurator{
}

public protocol DynamicCellsByNibs{
    func cellNibForReuseIdentifier(_ reuseIdentifier:String)->UINib?
}

public protocol DynamicHeaderFooterByNib{// The nib must contain an UITableViewHeaderFooterView
    func headerFooterNibForReuseIdentifier(_ reuseIdentifier:String)->UINib?
}

