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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func savePassword(_ sender: Any) {
        Task {
            guard UserDefaults.standard.object(forKey: "id") != nil else {
                showAlert(message: "No signed-in account was found.")
                return
            }
            
            let id = UserDefaults.standard.integer(forKey: "id")
            
            guard let oldPassword = oldPasswordInput.text,
                  let newPassword = newPasswordInput.text,
                  let confirmPassword = confirmPasswordInput.text,
                  !oldPassword.isEmpty,
                  !newPassword.isEmpty,
                  !confirmPassword.isEmpty
            else {
                showAlert(message: "Please fill in all password fields.")
                return
            }
            
            if newPassword != confirmPassword {
                showAlert(message: "Passwords do not match.")
                return
            }
            
            if !newPassword.contains(
                /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*?.,(){}\[\]<>;:~`_\-+=\\|'"])[A-Za-z\d!@#$%^&*?.,(){}\[\]<>;:~`_\-+=\\|'"]{8,}$/
            ) {
                showAlert(
                    message: "Password must be at least 8 characters long and contain at least 1 uppercase letter, lowercase letter, number, and special character."
                )
                return
            }
            
            let user = await getUserById(id: id)
            
            guard user.count > 2 else {
                showAlert(message: "Your account information could not be loaded.")
                return
            }
            
            let currentPassword = user[2]
            
            if oldPassword != currentPassword {
                showAlert(message: "Old password is incorrect.")
                return
            }
            
            if newPassword == currentPassword {
                showAlert(message: "Your new password must be different from your old password.")
                return
            }
            
            if let button = sender as? UIButton {
                button.isEnabled = false
            }
            
            let success = await updateUsersPasswordById(
                id: id,
                password: newPassword
            )
            
            await MainActor.run {
                if let button = sender as? UIButton {
                    button.isEnabled = true
                }
                
                if success {
                    let alert = UIAlertController(
                        title: "Password Updated",
                        message: "Your password has been updated successfully.",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default
                        ) { [weak self] _ in
                            self?.navigationController?
                                .popViewController(animated: true)
                        }
                    )
                    
                    self.present(alert, animated: true)
                    
                } else {
                    self.showAlert(
                        message: "Your password could not be updated. Please try again."
                    )
                }
            }
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
