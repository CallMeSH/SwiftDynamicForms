//
//  DynamicForms.swift
//  DynamicForms
//
//  Created by Benoit Pereira da Silva on 21/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.
//


import UIKit

public class CellConfigurator:Configurator{
}

public protocol DynamicCellsByNibs{
    func cellNibForReuseIdentifier(reuseIdentifier:String)->UINib?
}

public protocol DynamicHeaderFooterByNib{// The nib must contain an UITableViewHeaderFooterView
    func headerFooterNibForReuseIdentifier(reuseIdentifier:String)->UINib?
}

