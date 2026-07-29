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
            ) { [weak self] _ in
                
                guard let self = self else {
                    return
                }
                
                Task {
                    guard UserDefaults.standard.object(forKey: "id") != nil else {
                        await MainActor.run {
                            self.showDeleteError(
                                message: "No signed-in account was found."
                            )
                        }
                        return
                    }
                    
                    let id = UserDefaults.standard.integer(forKey: "id")
                    
                    let accountDeleted = await deleteUserById(id: id)
                    
                    await MainActor.run {
                        if accountDeleted {
                            UserDefaults.standard.removeObject(forKey: "id")
                            self.showAccountDeletedAlert()
                        } else {
                            self.showDeleteError(
                                message: "Your account could not be deleted. Please check your connection and try again."
                            )
                        }
                    }
                }
            }
        )
        
        present(alert, animated: true)
    }
    private func showAccountDeletedAlert() {
        let successAlert = UIAlertController(
            title: "Account Deleted",
            message: "Your account has been successfully deleted.",
            preferredStyle: .alert
        )
        
        successAlert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            ) { [weak self] _ in
                
                guard let self = self else {
                    return
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let signInVC = storyboard.instantiateViewController(
                    withIdentifier: "SignIn"
                )
                
                signInVC.modalPresentationStyle = .fullScreen
                self.present(signInVC, animated: true)
            }
        )
        
        present(successAlert, animated: true)
    }
    private func showDeleteError(message: String) {
        let errorAlert = UIAlertController(
            title: "Deletion Failed",
            message: message,
            preferredStyle: .alert
        )
        
        errorAlert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )
        
        present(errorAlert, animated: true)
    }
}
