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
            
            let onboardingAlert = UIAlertController(title: "Welcome to PhotoDrop!", message: "\nLook for gems on the map\n \nGems = Photos dropped by other users\n \nTap on a gem to find out how to navigate there\n \nIf you can make it to the gem, you'll be able to view it\n \nDrop and like photos to earn points!", preferredStyle: .alert)
            
            // background color
            let backView = onboardingAlert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 10.0
            backView?.backgroundColor = UIColor(colorLiteralRed: 82.0/255.0, green: 230.0/255.0, blue: 248.0/255.0, alpha: 1)
            
            // title font and text color
            
            let titleString  = "Welcome to PhotoDrop!"
            var titleMutableString = NSMutableAttributedString()
            titleMutableString = NSMutableAttributedString(string: titleString as String, attributes: [NSFontAttributeName:UIFont(name: "Abadi MT Condensed Extra Bold", size: 24.0)!])
            titleMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:titleString.characters.count))
            onboardingAlert.setValue(titleMutableString, forKey: "attributedTitle")
            
            // message font and text color
            
            let message  = "\nLook for gems on the map\n \nGems = Photos dropped by other users\n \nTap on a gem to find out how to navigate there\n \nIf you can make it to the gem, you'll be able to view it\n \nDrop and like photos to earn points!"
            var messageMutableString = NSMutableAttributedString()
            messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSFontAttributeName:UIFont(name: "Abadi MT Condensed Light", size: 18.0)!])
            messageMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:message.characters.count))
            onboardingAlert.setValue(messageMutableString, forKey: "attributedMessage")
            
            // action button text
            
            let action = UIAlertAction(title: "Got it!", style: .default, handler: nil)
            action.setValue(UIColor.white, forKey: "titleTextColor")
            onboardingAlert.addAction(action)
            onboardingAlert.present(onboardingAlert, animated: true, completion: nil)
        }
    }
}
