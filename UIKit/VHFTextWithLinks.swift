//
//  VHFLabelWithLinks.swift
//  SCMBImages
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 Azurgate. All rights reserved.
//

import UIKit

protocol VHFLinkDelegate{
    func interactWithURL (sender: AnyObject, URL:NSURL)
}


// Encapsulated configurator
class VHFLinkConfigurator:Configurator{
    
    var delegate:VHFLinkDelegate

    var attributedText:NSMutableAttributedString
    
    init(delegate:VHFLinkDelegate, attributedText:NSMutableAttributedString){
        self.delegate=delegate
        self.attributedText=attributedText
    }
}


//TODO: support class initialization 
//TODO: Height computation !!!

class VHFTextWithLinks: UITableViewHeaderFooterView, ComputedHeightView,UITextViewDelegate {
    
    var configurator:VHFLinkConfigurator?
    
    @IBOutlet weak var textView: UITextView!
    
    func configureWith(configurator:Configurator){
        if configurator is VHFLinkConfigurator{
            self.configurator = configurator as? VHFLinkConfigurator
            self.textView.attributedText = self.configurator?.attributedText
            self.textView.scrollEnabled = false
        }
    }
    
    func heightFor(dataSource:DynamicDataSource, constrainedToWidth width:CGFloat)->CGFloat{
        //return self.textViewHeight()
        // NOT FUNCTIONNING
        if let height = self.configurator?.attributedText.sizeConstrainedToWidth(width).height{
            return height 
        }
        return 0.0
    }
    // NOT FUNCTIONNING
    func textViewHeight()->CGFloat{
        let textContainerInset=self.textView.textContainerInset
        let textContainerHeight=self.textView.layoutManager.usedRectForTextContainer(self.textView.textContainer).size.height
        let height=textContainerHeight+textContainerInset.top+textContainerInset.bottom
        return height
    }

    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool{
        self.configurator?.delegate.interactWithURL(self.textView, URL: URL)
        return false // We want the delegate to decide what to do with the URL
    }
    
    

}
