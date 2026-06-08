//
//  Privacy.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-26.
//

import Foundation
import UIKit
import CoreData

class PrivacyViewController: UIViewController {
    
    @IBAction func changePasswordTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "change")
        self.navigationController?.pushViewController(createVC, animated: true)
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {

        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to permanently delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { _ in

                Task {

                    let id: Int = UserDefaults.standard.integer(forKey: "id")

                    await deleteUserById(id: id)

                    UserDefaults.standard.removeObject(forKey: "id")

                    await MainActor.run {

                        let successAlert = UIAlertController(
                            title: "Account Deleted",
                            message: "Your account has been successfully deleted.",
                            preferredStyle: .alert
                        )

                        successAlert.addAction(
                            UIAlertAction(
                                title: "OK",
                                style: .default
                            ) { _ in

                                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                                let signInVC = storyboard.instantiateViewController(
                                    withIdentifier: "SignIn"
                                )

                                signInVC.modalPresentationStyle = .fullScreen
                                self.present(signInVC, animated: true)
                            }
                        )

                        self.present(successAlert, animated: true)
                    }
                }
            }
        )

        present(alert, animated: true)
    }
}
