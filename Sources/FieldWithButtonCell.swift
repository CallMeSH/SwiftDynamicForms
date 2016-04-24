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

public class FieldWithButtonCellConfigurator:FieldCellConfigurator{
    
    public var action:(() -> Void)
    public var showButton:Bool
    
    public init(delegate:FieldWithButtonCellDelegate,showButton:Bool, valueGetter:()->String, valueHasChanged:(newValue:String, cellReference:FieldCell)->(), action:(() -> Void)){
        self.showButton=showButton
        self.action=action
        super.init(delegate: delegate, valueGetter: valueGetter, valueHasChanged:valueHasChanged)
    }
}


 public class FieldWithButtonCell:FieldCell{

    @IBOutlet weak var button: UIButton!
    
     override  public func configureWith(configurator:Configurator){
        if let configuratorInstance = configurator as? FieldWithButtonCellConfigurator {
            super.configureWith(configurator)
            button.hidden=(!configuratorInstance.showButton)
            button.addTarget(self, action: Selector("proceed:"), forControlEvents: UIControlEvents.TouchUpInside)
            if self.field.targetForAction("_hasChanged:", withSender: self) == nil {
                self.field.addTarget(self, action: "hasChanged:", forControlEvents: UIControlEvents.EditingChanged)
            }
        }else{
            self.textLabel?.text="FieldWithButtonCellConfigurator required"
        }
    }
    
    public func proceed(sender:UIButton){
        if let configuratorWithButton=self.configurator as? FieldWithButtonCellConfigurator {
            configuratorWithButton.action()
        }
    }
    
}