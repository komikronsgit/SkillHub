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
        let name: String? = UserDefaults.standard.string(forKey: "username")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name!)
        
        do {
            let results = try context.fetch(request)
            
            if let user = results.first {
                if oldPasswordInput.text != user.password {
                    showAlert(message: "Incorect old password")
                    return
                }
                
                if newPasswordInput.text != confirmPasswordInput.text {
                    showAlert(message: "New and confirm passwords don't match")
                    return
                }
                
                user.password = newPasswordInput.text
            }
            
            try context.save()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewController(withIdentifier: "privacy")
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
            
        } catch let error {
            print("Failed to update user password: \(error)")
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
