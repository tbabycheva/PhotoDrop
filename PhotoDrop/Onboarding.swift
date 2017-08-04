//
//  Onboarding.swift
//  PhotoDrop
//
//  Created by handje on 8/3/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import UIKit

class Onboarding {
    
    var onboardingOverlayHasBeenDisplayed = false
    
     func viewDidAppear(_ animated: Bool) {
        if onboardingOverlayHasBeenDisplayed == false {
            onboardingOverlayHasBeenDisplayed = true
            
            let alertController = UIAlertController(title: "Welcome to PhotoDrop!", message: "\nLook for gems on the map\n \nGems = Photos dropped by other users\n \nTap on a gem to find out how to navigate there\n \nIf you can make it to the gem, you'll be able to view it\n \nDrop and like photos to earn points!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            
           alertController.present(alertController, animated: true, completion: nil) 
            
        }
    }
}
