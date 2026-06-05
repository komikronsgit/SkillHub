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
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var programLable: UILabel!
    @IBOutlet weak var schoolLable: UILabel!
    @IBOutlet weak var aboutMeLable: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            let imageData = await getProfilePic()
            profilePicImage.image = UIImage(data: imageData)
            profilePicImage.contentMode = .scaleAspectFill
            profilePicImage.clipsToBounds = true
            
            let id: Int = UserDefaults.standard.integer(forKey: "id")
            
            let user = await getUserById(id: id)
            let name = user[0]
            let aboutMe = user[3]
            let program = user[4]
            let school = user[5]
            
            nameLable.text = name
            programLable.text = program
            schoolLable.text = school
            aboutMeLable.text = aboutMe
        }
    }
    
    @IBAction func openEditProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "settings")
        self.navigationController?.pushViewController(createVC, animated: true)
    }
}
