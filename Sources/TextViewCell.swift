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

 open class TextViewCellConfigurator:CellConfigurator{
    
    open var delegate:TextViewCellDelegate
    open var valueGetter:()->String
    open var valueHasChanged:(_ newValue:String, _ cellReference:TextViewCell)->()

    open var placeHolderText:String=""
    open var headerText:String=""
    open var footerText:String=""
    open var numberMaxOfChar:Int=Int.max
    
    public init(delegate:TextViewCellDelegate,valueGetter:@escaping ()->String, valueHasChanged:@escaping (_ newValue:String, _ cellReference:TextViewCell)->()){
        self.delegate=delegate
        self.valueGetter=valueGetter
        self.valueHasChanged=valueHasChanged
    }
}


 open class TextViewCell:UITableViewCell,Configurable, UITextViewDelegate {
    
    @IBOutlet weak open var textView: UITextView!
    @IBOutlet weak open var placeHolderLabel: UILabel?
    @IBOutlet weak open var headerLabel: UILabel?
    @IBOutlet weak open var footerLabel: UILabel?
    
    open var configurator:TextViewCellConfigurator?
    
     open func configureWith(_ configurator:Configurator){
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
    
     open func textViewDidChange(_ textView: UITextView) {
        if let newText=self.textView.text {
            self.placeHolderLabel?.isHidden = (newText.count > 0)
            self.configurator?.valueHasChanged(newText,self)
        }
    }
    
    
     open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let nbMax=self.configurator?.numberMaxOfChar {
            return (textView.text.count < nbMax) || text==""
        }
        return true
    }
   
     open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}
