//
//  EditProfile.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-25.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class EditProfileViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var profilePicInput: UIButton!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var schoolInput: UITextField!
    @IBOutlet weak var programInput: UITextField!
    @IBOutlet weak var bioInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await updateProfilePic()
            
            let id: Int = UserDefaults.standard.integer(forKey: "id")
            
            let user = await getUserById(id: id)
            let name = user[0]
            let email = user[1]
            let aboutMe = user[3]
            let program = user[4]
            let school = user[5]
            
            nameInput.text = name
            emailInput.text = email
            programInput.text = school
            schoolInput.text = program
            bioInput.text = aboutMe
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        Task {
            do {
                let data = try Data(contentsOf: url)
                let id = UserDefaults.standard.integer(forKey: "id")
                let ext = url.pathExtension
                await addOrUpdateProfilePic(path: "\(id).\(ext)", data: data)
                await updateProfilePic()
            } catch let error {
                print("failed to load image: \(error)")
            }
        }
    }
    
    @IBAction func changePicTapped(_ sender: UIButton) {
        let supportedTypes: [UTType] = [
            .image,
            .png,
            .jpeg,
        ]
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    @IBAction func saveEdit(_ sender: UIButton) {
        Task {
            let id: Int = UserDefaults.standard.integer(forKey: "id")
            
            let name = nameInput.text  ?? ""
            let email = emailInput.text  ?? ""
            let school = schoolInput.text  ?? ""
            let program = programInput.text  ?? ""
            let aboutMe = bioInput.text ?? ""
            
            await updateUserById(id: id, name: name, email: email, about_me: aboutMe, program: program, school: school)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewController(withIdentifier: "Profile")
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
        }
    }
    
    private func updateProfilePic() async {
        let imageData = await getProfilePic()
        profilePicInput.setImage(UIImage(data: imageData), for: .normal)
        profilePicInput.imageView?.contentMode = .scaleAspectFill
        profilePicInput.clipsToBounds = true
    }
}
