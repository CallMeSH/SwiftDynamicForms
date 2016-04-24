//
//  VHFLabelWithLinks.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 Azurgate. All rights reserved.
//

import UIKit

public protocol VHFLinkDelegate{
    func interactWithURL (sender: AnyObject, URL:NSURL)
}


// Encapsulated configurator
public class VHFLinkConfigurator:Configurator{
    
    public var delegate:VHFLinkDelegate

    public var attributedText:NSMutableAttributedString
    
    public init(delegate:VHFLinkDelegate, attributedText:NSMutableAttributedString){
        self.delegate=delegate
        self.attributedText=attributedText
    }
}


//TODO: support class initialization 
//TODO: Height computation !!!

public class VHFTextWithLinks: UITableViewHeaderFooterView, ComputedHeightView,UITextViewDelegate {
    
    public var configurator:VHFLinkConfigurator?
    
    @IBOutlet weak var textView: UITextView!
    
    public func configureWith(configurator:Configurator){
        if configurator is VHFLinkConfigurator{
            self.configurator = configurator as? VHFLinkConfigurator
            self.textView.attributedText = self.configurator?.attributedText
            self.textView.scrollEnabled = false
        }
    }
    
    public func heightFor(dataSource:DynamicDataSource, constrainedToWidth width:CGFloat)->CGFloat{
        //return self.textViewHeight()
        // NOT FUNCTIONNING
        if let height = self.configurator?.attributedText.sizeConstrainedToWidth(width).height{
            return height 
        }
        return 0.0
    }
    // NOT FUNCTIONNING
    public func textViewHeight()->CGFloat{
        let textContainerInset=self.textView.textContainerInset
        let textContainerHeight=self.textView.layoutManager.usedRectForTextContainer(self.textView.textContainer).size.height
        let height=textContainerHeight+textContainerInset.top+textContainerInset.bottom
        return height
    }

    
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool{
        self.configurator?.delegate.interactWithURL(self.textView, URL: URL)
        return false // We want the delegate to decide what to do with the URL
    }
    
    

}
