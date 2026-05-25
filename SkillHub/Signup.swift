//
//  Signup.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-05-25.
//

import Foundation
import UIKit
import CoreData

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {

        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              !name.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {

            showAlert(message: "Please fill all fields")
            return
        }

        if password != confirmPassword {

            showAlert(message: "Passwords do not match")
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let user = User(context: context)

        user.name = name
        user.email = email
        user.password = password

        do {

            try context.save()

            showAlert(message: "Account Created Successfully")

            navigationController?.popViewController(animated: true)

        } catch {

            print("Failed to save user")
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
