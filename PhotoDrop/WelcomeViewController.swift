//
//  WelcomeViewController.swift
//  PhotoDrop
//
//  Created by handje on 7/27/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func userNameSubmitButtonTapped(_ sender: Any) {
        if let username = userNameTextField.text, !username.isEmpty {
            PhotoDropUserController.shared.createCurrentUserWith(username: username)
        }
    }
}
