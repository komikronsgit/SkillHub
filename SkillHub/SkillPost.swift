//
//  SkillPost.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-05-25.
//

import UIKit
import CoreData

class SkillPostViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var availabilityTextField: UITextField!
    @IBOutlet weak var contactEmailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func postSkillTapped(_ sender: UIButton) {
        Task {
            guard let title = titleTextField.text, !title.isEmpty,
                  let postDescription = descriptionTextField.text, !postDescription.isEmpty,
                  let category = categoryTextField.text, !category.isEmpty,
                  let availability = availabilityTextField.text, !availability.isEmpty,
                  let contactEmail = contactEmailTextField.text, !contactEmail.isEmpty else {

                showAlert(message: "Please fill all fields")
                return
            }
            
            let posterId = UserDefaults.standard.integer(forKey: "id")
            
            await addSkillPost(title: title, category: category, description: postDescription, avalibility: availability, contact_email: contactEmail, poster_id: posterId)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewController(withIdentifier: "Marketplace")
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
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
