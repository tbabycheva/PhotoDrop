//
//  SettingsViewController.swift
//  PhotoDrop
//
//  Created by Kenny Peterson on 7/24/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var changeUsernameTextField: UITextField!
    @IBOutlet weak var currentUsernameLabel: UILabel!
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
        modalTransitionStyle = .flipHorizontal
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeUsernameTextField.delegate = self
        
        guard let text = PhotoDropUserController.shared.currentPhotoDropUser?.username else { return }
        
        currentUsernameLabel.text = "\(text)"
    }
    
    
    // MARK: - Appearance
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeUsernameTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - Action Functions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let text = changeUsernameTextField.text else { return }
        
        if text.characters.count < 6 {
            
            let characterAlert = UIAlertController(title: "Oops!", message: "New username must be 6 or more characters", preferredStyle: .alert)
            characterAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(characterAlert, animated: true, completion: nil)
            
        } else if text.characters.count > 25 {
            let characterAlert = UIAlertController(title: "Oops!", message: "Oops! New username must be less than 25 characters", preferredStyle: .alert)
            characterAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(characterAlert, animated: true, completion: nil)
        } else {
            
            PhotoDropUserController.shared.changeUserName(username: text)
            
            dismiss(animated: true, completion: nil)
        }
    }
}
