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
        createVC.modalPresentationStyle = .fullScreen
        present(createVC, animated: true)
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        let name: String? = UserDefaults.standard.string(forKey: "username")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name!)
        
        do {
            let results = try context.fetch(request)
            
            if let user = results.first {
                context.delete(user)
            }
            
            try context.save()
            
            UserDefaults.standard.set(nil, forKey: "username")
            UserDefaults.standard.set(nil, forKey: "userEmail")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewController(withIdentifier: "SignIn")
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
            
        } catch let error {
            print("Failed to delete user: \(error)")
        }
    }
}
