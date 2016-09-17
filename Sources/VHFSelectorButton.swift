//
//  VHFSelectorButton
//  DynamicForms
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.
//

import UIKit

public protocol VHFSelectorDelegate{
    func didSelect(_ sender: VHFSelectorButton)
}

// Encapsulated configurator 
open class VHFSelectorConfigurator:Configurator{
    open var delegate:VHFSelectorDelegate
    public init(delegate:VHFSelectorDelegate){
        self.delegate=delegate
    }
}

//TODO: support class initialization 

open class VHFSelectorButton: UITableViewHeaderFooterView, Configurable {

    @IBOutlet weak open var button: UIButton!
    
    @IBOutlet weak open var imageView: UIImageView?
    
    open var configurator:VHFSelectorConfigurator?
    
    @IBAction func selectImage(_ sender: AnyObject) {
        if  self.configurator != nil {
            self.configurator!.delegate.didSelect(self)
        }
    }
    
    open func configureWith(_ configurator:Configurator){
        if configurator is VHFSelectorConfigurator{
            self.configurator = configurator as? VHFSelectorConfigurator
            // Proceed to configuration
        }
    }


}
