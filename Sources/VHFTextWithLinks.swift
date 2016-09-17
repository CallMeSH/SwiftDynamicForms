//
//  VHFLabelWithLinks.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 Azurgate. All rights reserved.
//

import UIKit

public protocol VHFLinkDelegate{
    func interactWithURL (_ sender: AnyObject, URL:URL)
}


// Encapsulated configurator
open class VHFLinkConfigurator:Configurator{
    
    open var delegate:VHFLinkDelegate

    open var attributedText:NSMutableAttributedString
    
    public init(delegate:VHFLinkDelegate, attributedText:NSMutableAttributedString){
        self.delegate=delegate
        self.attributedText=attributedText
    }
}


//TODO: support class initialization 
//TODO: Height computation !!!

open class VHFTextWithLinks: UITableViewHeaderFooterView, ComputedHeightView,UITextViewDelegate {
    
    open var configurator:VHFLinkConfigurator?
    
    @IBOutlet weak var textView: UITextView!
    
    open func configureWith(_ configurator:Configurator){
        if configurator is VHFLinkConfigurator{
            self.configurator = configurator as? VHFLinkConfigurator
            self.textView.attributedText = self.configurator?.attributedText
            self.textView.isScrollEnabled = false
        }
    }
    
    open func heightFor(_ dataSource:DynamicDataSource, constrainedToWidth width:CGFloat)->CGFloat{
        //return self.textViewHeight()
        // NOT FUNCTIONNING
        if let height = self.configurator?.attributedText.sizeConstrainedToWidth(width).height{
            return height 
        }
        return 0.0
    }
    // NOT FUNCTIONNING
    open func textViewHeight()->CGFloat{
        let textContainerInset=self.textView.textContainerInset
        let textContainerHeight=self.textView.layoutManager.usedRect(for: self.textView.textContainer).size.height
        let height=textContainerHeight+textContainerInset.top+textContainerInset.bottom
        return height
    }

    
    open func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool{
        self.configurator?.delegate.interactWithURL(self.textView, URL: URL)
        return false // We want the delegate to decide what to do with the URL
    }
    
    

}
