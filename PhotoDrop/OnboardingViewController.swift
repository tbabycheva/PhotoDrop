//
//  OnboardingViewController.swift
//  PhotoDrop
//
//  Created by handje on 8/4/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var gemListBubble: UIImageView!
    @IBOutlet weak var gemInfoBubble: UIImageView!
    @IBOutlet weak var radiusBubble: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        gemInfoBubble.pulsate()
        gemListBubble.pulsate()
        radiusBubble.pulsate()
    }
    
    @IBAction func gotItButtonTapped(_ sender: UIButton) {
    }
}

extension UIImageView {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 4.0
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
}
