//
//  Signin.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-05-21.
//

import Foundation
import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        Task {
            guard let email = emailTextField.text,
                  let password = passwordTextField.text,
                  !email.isEmpty,
                  !password.isEmpty else {

                showAlert(message: "Please enter email and password")
                return
            }
            
            let id = await getUsersIdByEmail(email: email)
            
            if id == -1 {
                showAlert(message: "Invalid email or password")
                return
            }
            
            let user = await getUserById(id: id)
            let correctPassword = user[2]
            
            if password == correctPassword {
                UserDefaults.standard.set(id, forKey: "id")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController

                tabBarVC.selectedIndex = 0
                tabBarVC.modalPresentationStyle = .fullScreen

                present(tabBarVC, animated: true)
            } else {
                showAlert(message: "Invalid email or password")
            }
        }
    }

    @IBAction func signUpTapped(_ sender: UIButton) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUp")

        navigationController?.pushViewController(signUpVC, animated: true)
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
