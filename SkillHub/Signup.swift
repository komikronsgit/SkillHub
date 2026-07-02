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
            
            if !password.contains(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*?.,(){}\[\]<>;:~`_\-+=\\|'"])[A-Za-z\d!@#$%^&*?.,(){}\[\]<>;:~`_\-+=\\|'"]{8,}$/) {
                showAlert(message: "Password must be at least 8 characters long and contain at least 1 uppercase letter, lowercase letter, number, and special character")
            }

            if !email.contains(/^[A-Za-z\d]+@[A-Za-z\d]+\.[a-z]{2,}$/) {
                showAlert(message: "Please enter a valid email address")
            }
            
            await addUser(name: name, email: email, password: password, about_me: "", program: "", school: "")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewController(withIdentifier: "SignIn")
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
        }
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
