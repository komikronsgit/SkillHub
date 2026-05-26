//
//  EditProfile.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-25.
//

import Foundation
import UIKit
import CoreData

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var schoolInput: UITextField!
    @IBOutlet weak var programInput: UITextField!
    @IBOutlet weak var bioInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name: String? = UserDefaults.standard.string(forKey: "username")
   
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name!)
        
        do {
            let results = try context.fetch(request)
            
            if let user = results.first {
                nameInput.text = user.name
                emailInput.text = user.email
                schoolInput.text = user.school
                programInput.text = user.program
                bioInput.text = user.aboutMe
            }
            
        } catch let error {
            print("Failed to get user: \(error)")
        }
        
    }
    
    @IBAction func saveEdit(_ sender: UIButton) {

        let name: String? = UserDefaults.standard.string(forKey: "username")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name!)
        
        
        do {
            let results = try context.fetch(request)
            
            if let user = results.first {
                user.name = nameInput.text
                user.email = emailInput.text
                user.school = schoolInput.text
                user.program = programInput.text
                user.aboutMe = bioInput.text
                
                UserDefaults.standard.set(user.name, forKey: "username")
                UserDefaults.standard.set(user.email, forKey: "userEmail")
            }
            
            try context.save()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewController(withIdentifier: "Profile")
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
        } catch let error {
            print("Failed to update user: \(error)")
        }
    }
}
