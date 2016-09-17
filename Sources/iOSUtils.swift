//
//  DynamicForms.swift
//  DynamicForms
//
//  Created by Benoit Pereira da Silva on 21/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.

import UIKit

//MARK: Device management

// As a best pratice i consider that we should not distinguish precisely phones
// Size Class should be used to variate the context

public struct D{
    public static let is_PAD = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    public static let is_PHONE = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    public static let is_UNSPECIFIED = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.unspecified
    public static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    public static let iOS7 = (D.SYS_VERSION_FLOAT < 8.0 && D.SYS_VERSION_FLOAT >= 7.0)
    public static let iOS8 = (D.SYS_VERSION_FLOAT >= 8.0 && D.SYS_VERSION_FLOAT < 9.0)
    public static let iOS9 = (D.SYS_VERSION_FLOAT >= 9.0 && D.SYS_VERSION_FLOAT < 10.0)
}

// Generic extensions

extension UIFont {
    public func sizeOfString (_ string: String, constrainedToWidth width: CGFloat) -> CGSize {
        let maxSize=CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options : NSStringDrawingOptions = [NSStringDrawingOptions.usesLineFragmentOrigin , NSStringDrawingOptions.usesFontLeading]
        return NSString(string: string).boundingRect(with: maxSize,
            options: options,
            attributes: [NSFontAttributeName: self], context: nil).size
    }
}

extension NSMutableAttributedString {
    
    public func setFragmentAsLink(_ textToFind:String, linkURL:URL) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }    
}


extension NSAttributedString {
    
    public func sizeConstrainedToWidth(_ width: CGFloat) -> CGSize {
        let maxSize=CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options : NSStringDrawingOptions = [NSStringDrawingOptions.usesLineFragmentOrigin , NSStringDrawingOptions.usesFontLeading]
        return self.boundingRect(with: maxSize,
            options: options,
            context: nil).size
    }
}
