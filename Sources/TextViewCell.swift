//
//  TextViewCell.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 Azurgate. All rights reserved.
//



// MARK : - SingleObjectReferenceCellDelegate

protocol TextViewCellDelegate{
}

public class TextViewCellConfigurator:CellConfigurator{
    
    var delegate:TextViewCellDelegate
    var valueGetter:()->String
    var valueHasChanged:(newValue:String, cellReference:TextViewCell)->()

    var placeHolderText:String=""
    var headerText:String=""
    var footerText:String=""
    var numberMaxOfChar:Int=Int.max
    
    init(delegate:TextViewCellDelegate,valueGetter:()->String, valueHasChanged:(newValue:String, cellReference:TextViewCell)->()){
        self.delegate=delegate
        self.valueGetter=valueGetter
        self.valueHasChanged=valueHasChanged
    }
}


public class TextViewCell:UITableViewCell,Configurable, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel?
    @IBOutlet weak var headerLabel: UILabel?
    @IBOutlet weak var footerLabel: UILabel?
    
    var configurator:TextViewCellConfigurator?
    
    func configureWith(configurator:Configurator){
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
    
    func textViewDidChange(textView: UITextView) {
        if let newText=self.textView.text {
            self.placeHolderLabel?.hidden = (newText.characters.count > 0)
            self.configurator?.valueHasChanged(newValue:newText,cellReference:self)
        }
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let nbMax=self.configurator?.numberMaxOfChar {
            return (textView.text.characters.count < nbMax) || text==""
        }
        return true
    }
   
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}