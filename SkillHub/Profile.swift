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
    @IBOutlet weak var aboutMeLable: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = UserDefaults.standard.string(forKey: "username")

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name!)
        
        do {
            let results = try context.fetch(request)
            
            if let user = results.first {
                nameLable.text = user.name
                aboutMeLable.text = user.aboutMe
            }
            
        } catch let error {
            print("Failed to get user: \(error)")
        }
        
    }
}
