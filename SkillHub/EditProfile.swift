//
//  EditProfile.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-25.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import PhotosUI

class EditProfileViewController: UIViewController, PHPickerViewControllerDelegate {
    
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
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { image, error in

            DispatchQueue.main.async {

                if let image = image as? UIImage {

                    self.profilePicInput.setImage(image, for: .normal)
                    self.profilePicInput.imageView?.contentMode = .scaleAspectFill
                    self.profilePicInput.clipsToBounds = true

                    if let data = image.jpegData(compressionQuality: 0.8) {

                        let id = UserDefaults.standard.integer(forKey: "id")

                        Task {
                            await addOrUpdateProfilePic(
                                path: "\(id).jpg",
                                data: data
                            )

                            await self.updateProfilePic()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func changePicTapped(_ sender: UIButton) {

        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self

        present(picker, animated: true)
    }
    
    @IBAction func saveEdit(_ sender: UIButton) {
        Task {
            let id: Int = UserDefaults.standard.integer(forKey: "id")
            
            let name = nameInput.text ?? ""
            let email = emailInput.text ?? ""
            let school = schoolInput.text ?? ""
            let program = programInput.text ?? ""
            let aboutMe = bioInput.text ?? ""
            
            await updateUserById(
                id: id,
                name: name,
                email: email,
                about_me: aboutMe,
                program: program,
                school: school
            )
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func updateProfilePic() async {
        let imageData = await getProfilePic()
        profilePicInput.setImage(UIImage(data: imageData), for: .normal)
        profilePicInput.imageView?.contentMode = .scaleAspectFill
        profilePicInput.clipsToBounds = true
    }
}
