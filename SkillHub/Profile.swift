//
//  Profile.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-25.
//

import Foundation
import UIKit
import CoreData

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var programLable: UILabel!
    @IBOutlet weak var schoolLable: UILabel!
    @IBOutlet weak var aboutMeLable: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name: String? = UserDefaults.standard.string(forKey: "username")
   
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name!)
        
        do {
            let results = try context.fetch(request)
            
            if let user = results.first {
                nameLable.text = user.name
                programLable.text = user.program
                schoolLable.text = user.school
                aboutMeLable.text = user.aboutMe
            }
            
        } catch let error {
            print("Failed to get user: \(error)")
        }
        
    }
    
    @IBAction func openEditProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "settings")
        createVC.modalPresentationStyle = .fullScreen
        present(createVC, animated: true)
    }

}
