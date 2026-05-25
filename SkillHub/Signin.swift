//
//  Signin.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-05-21.
//

import Foundation
import UIKit
import CoreData

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginTapped(_ sender: UIButton) {

        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty,
              !password.isEmpty else {

            showAlert(message: "Please enter email and password")
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)

        do {
            let results = try context.fetch(request)

            if let user = results.first {

                UserDefaults.standard.set(user.name, forKey: "username")
                UserDefaults.standard.set(user.email, forKey: "userEmail")

                print("Login Successful")
                print("Logged in user: \(user.name ?? "")")
                print("Logged in email: \(user.email ?? "")")

                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController

                tabBarVC.selectedIndex = 0
                tabBarVC.modalPresentationStyle = .fullScreen

                present(tabBarVC, animated: true)

            } else {
                showAlert(message: "Invalid email or password")
            }

        } catch {
            print("Core Data Fetch Error")
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
