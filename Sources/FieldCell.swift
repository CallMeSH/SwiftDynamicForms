//
//  FieldCell.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 Azurgate. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


public protocol FieldCellDelegate{
}

open class FieldCellConfigurator:CellConfigurator{
    
    open var labelText:String? // Often a descriptive label
    open var placeHolderText:String? // The placeholder within the field
    
    
    open var delegate:FieldCellDelegate
    open var valueGetter:()->String
    open var valueHasChanged:(_ newValue:String, _ cellReference:FieldCell)->()
    open var numberMaxOfChar:Int=Int.max
    
    public init(delegate:FieldCellDelegate, valueGetter:@escaping ()->String, valueHasChanged:@escaping (_ newValue:String, _ cellReference:FieldCell)->()){
        self.delegate=delegate
        self.valueGetter=valueGetter
        self.valueHasChanged=valueHasChanged
    }
}


//MARK : -  Fields and text views

open class FieldCell:UITableViewCell,Configurable,Validable,UITextFieldDelegate{
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var field: UITextField!
    
    
    open var configurator:FieldCellConfigurator?
    
    open func configureWith(_ configurator:Configurator){
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
        if self.field.target(forAction: #selector(FieldCell.hasChanged(_:)), withSender: self) == nil {
            self.field.addTarget(self, action: #selector(FieldCell.hasChanged(_:)), for: UIControl.Event.editingChanged)
        }
    }
    
    
    @objc open func hasChanged(_ sender:UITextField){
        self.configurator?.valueHasChanged(self.field.text!,self)
    }
    
    
    open func validate()->(result:Bool,message:String){
        return (true,"")
    }
    
    
    open func  textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let nbMax=self.configurator?.numberMaxOfChar {
            return textField.text?.count<nbMax || string==""
        }
        return true
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
}

