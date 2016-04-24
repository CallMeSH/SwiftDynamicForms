//
//  VHFSelectorButton
//  DynamicForms
//
//  Created by Benoit Pereira da Silva on 22/04/2015.
//  Copyright (c) 2015 http://pereira-da-silva.com  All rights reserved.
//

import UIKit

protocol VHFSelectorDelegate{
    func didSelect(sender: VHFSelectorButton)
}

// Encapsulated configurator
class VHFSelectorConfigurator:Configurator{
    var delegate:VHFSelectorDelegate
    init(delegate:VHFSelectorDelegate){
        self.delegate=delegate
    }
}

//TODO: support class initialization 

class VHFSelectorButton: UITableViewHeaderFooterView, Configurable {

    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var imageView: UIImageView?
    
    var configurator:VHFSelectorConfigurator?
    
    @IBAction func selectImage(sender: AnyObject) {
        if  self.configurator != nil {
            self.configurator!.delegate.didSelect(self)
        }
    }
    
    func configureWith(configurator:Configurator){
        if configurator is VHFSelectorConfigurator{
            self.configurator = configurator as? VHFSelectorConfigurator
            // Proceed to configuration
        }
    }


}
