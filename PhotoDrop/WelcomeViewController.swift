//
//  WelcomeViewController.swift
//  PhotoDrop
//
//  Created by handje on 7/27/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
    }
    
    // MARK: - Appearance
    // Lock tableview in portrait mode
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    @IBAction func userNameSubmitButtonTapped(_ sender: Any) {
        if let username = userNameTextField.text, !username.isEmpty {
            
            if username.characters.count >= 4 {
                
                PhotoDropUserController.shared.createCurrentUserWith(username: username, completion: {
                    DropController.shared.updateInRangeDrops()
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toMapView", sender: nil)
                    }
                })
                
            } else {
                
                let alert = UIAlertController(title: "Invalid", message: "Username must contain four or more characters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userNameTextField.resignFirstResponder()
        return true
    }
}
