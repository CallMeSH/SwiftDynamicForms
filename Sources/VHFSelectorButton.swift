//
//  VHFSelectorButton
//  DynamicForms
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.
//

import UIKit

public protocol VHFSelectorDelegate{
    func didSelect(sender: VHFSelectorButton)
}

// Encapsulated configurator 
public class VHFSelectorConfigurator:Configurator{
    public var delegate:VHFSelectorDelegate
    public init(delegate:VHFSelectorDelegate){
        self.delegate=delegate
    }
}

//TODO: support class initialization 

public class VHFSelectorButton: UITableViewHeaderFooterView, Configurable {

    @IBOutlet weak public var button: UIButton!
    
    @IBOutlet weak public var imageView: UIImageView?
    
    public var configurator:VHFSelectorConfigurator?
    
    @IBAction func selectImage(sender: AnyObject) {
        if  self.configurator != nil {
            self.configurator!.delegate.didSelect(self)
        }
    }
    
    public func configureWith(configurator:Configurator){
        if configurator is VHFSelectorConfigurator{
            self.configurator = configurator as? VHFSelectorConfigurator
            // Proceed to configuration
        }
    }


}
