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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        changeUsernameTextField.delegate = self
        
        guard let text = PhotoDropUserController.shared.currentPhotoDropUser?.username else { return }
        
        currentUsernameLabel.text = "Current Username is: \(text)"
    }
   
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }

    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        
        guard let text = changeUsernameTextField.text else { return }
            
        if text.characters.count < 4 {
            
            let characterAlert = UIAlertController(title: "Invalid", message: "New username must be four or more characters", preferredStyle: .alert)
            characterAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(characterAlert, animated: true, completion: nil)
            
        } else {
    
            PhotoDropUserController.shared.changeUserName(username: text)
            
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeUsernameTextField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
