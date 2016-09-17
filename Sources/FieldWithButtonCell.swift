//
//  FieldWithButtonCell.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 Azurgate. All rights reserved.
//


// Mark : FieldWithButtonCell

import UIKit

public protocol FieldWithButtonCellDelegate:FieldCellDelegate{
}

open class FieldWithButtonCellConfigurator:FieldCellConfigurator{
    
    open var action:(() -> Void)
    open var showButton:Bool
    
    public init(delegate:FieldWithButtonCellDelegate,showButton:Bool, valueGetter:@escaping ()->String, valueHasChanged:@escaping (_ newValue:String, _ cellReference:FieldCell)->(), action:@escaping (() -> Void)){
        self.showButton=showButton
        self.action=action
        super.init(delegate: delegate, valueGetter: valueGetter, valueHasChanged:valueHasChanged)
    }
}


 open class FieldWithButtonCell:FieldCell{

    @IBOutlet weak var button: UIButton!
    
     override  open func configureWith(_ configurator:Configurator){
        if let configuratorInstance = configurator as? FieldWithButtonCellConfigurator {
            super.configureWith(configurator)
            button.isHidden=(!configuratorInstance.showButton)
            button.addTarget(self, action: #selector(FieldWithButtonCell.proceed(_:)), for: UIControlEvents.touchUpInside)
            if self.field.target(forAction: "_hasChanged:", withSender: self) == nil {
                self.field.addTarget(self, action: "hasChanged:", for: UIControlEvents.editingChanged)
            }
        }else{
            self.textLabel?.text="FieldWithButtonCellConfigurator required"
        }
    }
    
    open func proceed(_ sender:UIButton){
        if let configuratorWithButton=self.configurator as? FieldWithButtonCellConfigurator {
            configuratorWithButton.action()
        }
    }
    
}
