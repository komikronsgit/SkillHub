//
//  Signup.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-05-25.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {
        Task {
            guard let name = nameTextField.text,
                  let email = emailTextField.text,
                  let password = passwordTextField.text,
                  let confirmPassword = confirmPasswordTextField.text,
                  !name.isEmpty,
                  !email.isEmpty,
                  !password.isEmpty,
                  !confirmPassword.isEmpty
            else {
                showAlert(message: "Please fill all fields")
                return
            }
            
            if password != confirmPassword {
                showAlert(message: "Passwords do not match")
                return
            }
            
            if !password.contains(
                /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*?.,(){}\[\]<>;:~`_\-+=\\|'"])[A-Za-z\d!@#$%^&*?.,(){}\[\]<>;:~`_\-+=\\|'"]{8,}$/
            ) {
                showAlert(
                    message: "Password must be at least 8 characters long and contain at least 1 uppercase letter, lowercase letter, number, and special character"
                )
                return
            }
            
            if !email.contains(/^[A-Za-z\d]+@[A-Za-z\d]+\.[a-z]{2,}$/) {
                showAlert(message: "Please enter a valid email address")
                return
            }
            
            sender.isEnabled = false
            
            let accountCreated = await addUser(
                name: name,
                email: email,
                password: password,
                about_me: "",
                program: "",
                school: ""
            )
            
            sender.isEnabled = true
            
            if accountCreated {
                showAccountCreatedAlert()
            } else {
                showAlert(
                    message: "The account could not be created. The email may already be registered, or there may be a connection problem."
                )
            }
        }
    }
    func showAccountCreatedAlert() {
        let alert = UIAlertController(
            title: "Account Created",
            message: "Your SkillHub account has been created successfully.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "Sign In", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        
        present(alert, animated: true)
    }
    @IBAction func signInTapped(_ sender: UIButton) {

        navigationController?.popViewController(animated: true)
    }

    func showAlert(message: String) {

        let alert = UIAlertController(title: "SkillHub",
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))

        present(alert, animated: true)
    }
}
