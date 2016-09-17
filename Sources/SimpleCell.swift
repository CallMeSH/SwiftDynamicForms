//
//  Cells.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 21/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.
//

import UIKit



// A cell that does not require real configuration

public protocol SimpleCellDelegate{
}


open class SimpleCellConfigurator:CellConfigurator{
    var delegate:SimpleCellDelegate
    init(delegate:SimpleCellDelegate){
        self.delegate=delegate
    }
}

open class SimpleCell:UITableViewCell,Configurable{
    
    open var configurator:SimpleCellConfigurator?
    open func configureWith(_ configurator:Configurator){
        if let configuratorInstance = configurator as? SimpleCellConfigurator {
            self.configurator = configuratorInstance
        }else{
            self.textLabel?.text="CellConfigurator required"
        }
    }
}
