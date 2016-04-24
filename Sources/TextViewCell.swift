//
//  TextViewCell.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 Azurgate. All rights reserved.
//



// MARK : - SingleObjectReferenceCellDelegate

public protocol TextViewCellDelegate{
}

 public class TextViewCellConfigurator:CellConfigurator{
    
    public var delegate:TextViewCellDelegate
    public var valueGetter:()->String
    public var valueHasChanged:(newValue:String, cellReference:TextViewCell)->()

    public var placeHolderText:String=""
    public var headerText:String=""
    public var footerText:String=""
    public var numberMaxOfChar:Int=Int.max
    
    public init(delegate:TextViewCellDelegate,valueGetter:()->String, valueHasChanged:(newValue:String, cellReference:TextViewCell)->()){
        self.delegate=delegate
        self.valueGetter=valueGetter
        self.valueHasChanged=valueHasChanged
    }
}


 public class TextViewCell:UITableViewCell,Configurable, UITextViewDelegate {
    
    @IBOutlet weak public var textView: UITextView!
    @IBOutlet weak public var placeHolderLabel: UILabel?
    @IBOutlet weak public var headerLabel: UILabel?
    @IBOutlet weak public var footerLabel: UILabel?
    
    public var configurator:TextViewCellConfigurator?
    
     public func configureWith(configurator:Configurator){
        if let configuratorInstance = configurator as? TextViewCellConfigurator {
            self.configurator = configuratorInstance
            self.headerLabel?.text = configuratorInstance.headerText
            self.textView.text = configuratorInstance.valueGetter()
            self.textView.delegate=self
            self.placeHolderLabel?.text = configuratorInstance.placeHolderText
            self.footerLabel?.text = configuratorInstance.footerText
        }else{
            self.textView.text="TextViewCellConfigurator required"
        }
    }
    
     public func textViewDidChange(textView: UITextView) {
        if let newText=self.textView.text {
            self.placeHolderLabel?.hidden = (newText.characters.count > 0)
            self.configurator?.valueHasChanged(newValue:newText,cellReference:self)
        }
    }
    
    
     public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let nbMax=self.configurator?.numberMaxOfChar {
            return (textView.text.characters.count < nbMax) || text==""
        }
        return true
    }
   
     public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}