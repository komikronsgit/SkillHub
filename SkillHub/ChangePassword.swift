//
//  ChangePassword.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-26.
//

import Foundation
import UIKit
import CoreData

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var oldPasswordInput: UITextField!
    @IBOutlet weak var newPasswordInput: UITextField!
    @IBOutlet weak var confirmPasswordInput: UITextField!
    
    @IBAction func savePassword(_ sender: Any) {
        Task {
            let id: Int = UserDefaults.standard.integer(forKey: "id")
            
            let user = await getUserById(id: id)
            let password = user[2]
            
            if newPasswordInput.text == nil {
                showAlert(message: "you must enter a new password")
                return
            }
            
            if newPasswordInput.text != confirmPasswordInput.text {
                showAlert(message: "passwords do not match")
                return
            }
            
            if oldPasswordInput.text != password {
                showAlert(message: "old password is incorrect")
                return
            }
            
            await updateUsersPasswordById(id: id, password: newPasswordInput.text!)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewController(withIdentifier: "privacy")
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
        }
    }
    
    func showAlert(message: String) {

        let alert = UIAlertController(
            title: "SkillHub",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(alert, animated: true)
    }
    
}
