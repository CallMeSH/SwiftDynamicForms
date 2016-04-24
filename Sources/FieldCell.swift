//
//  FieldCell.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 Azurgate. All rights reserved.
//

import UIKit

public protocol FieldCellDelegate{
}

public class FieldCellConfigurator:CellConfigurator{
    
    public var labelText:String? // Often a descriptive label
    public var placeHolderText:String? // The placeholder within the field
    
    
    public var delegate:FieldCellDelegate
    public var valueGetter:()->String
    public var valueHasChanged:(newValue:String, cellReference:FieldCell)->()
    public var numberMaxOfChar:Int=Int.max
    
    public init(delegate:FieldCellDelegate, valueGetter:()->String, valueHasChanged:(newValue:String, cellReference:FieldCell)->()){
        self.delegate=delegate
        self.valueGetter=valueGetter
        self.valueHasChanged=valueHasChanged
    }
}


//MARK : -  Fields and text views

public class FieldCell:UITableViewCell,Configurable,Validable,UITextFieldDelegate{
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var field: UITextField!
    
    
    public var configurator:FieldCellConfigurator?
    
    public func configureWith(configurator:Configurator){
        self.field.delegate=self
        if let configuratorInstance = configurator as? FieldCellConfigurator {
            self.configurator = configuratorInstance
            self.field.text = configuratorInstance.valueGetter()
            self.field.delegate=self
            if let placeHolderText=configuratorInstance.placeHolderText{
                self.field.placeholder = placeHolderText
            }
            if let labelText=configuratorInstance.labelText{
                self.label.text = labelText
            }
        }else{
            self.field.text="FieldCellConfigurator required"
        }
        if self.field.targetForAction("hasChanged:", withSender: self) == nil {
            self.field.addTarget(self, action: "hasChanged:", forControlEvents: UIControlEvents.EditingChanged)
        }
    }
    
    
    public func hasChanged(sender:UITextField){
        self.configurator?.valueHasChanged(newValue:self.field.text!,cellReference:self)
    }
    
    
    public func validate()->(result:Bool,message:String){
        return (true,"")
    }
    
    
    public func  textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let nbMax=self.configurator?.numberMaxOfChar {
            return textField.text?.characters.count<nbMax || string==""
        }
        return true
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
}

