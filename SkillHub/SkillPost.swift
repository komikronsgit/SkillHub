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

        guard let title = titleTextField.text, !title.isEmpty,
              let postDescription = descriptionTextField.text, !postDescription.isEmpty,
              let category = categoryTextField.text, !category.isEmpty,
              let availability = availabilityTextField.text, !availability.isEmpty,
              let contactEmail = contactEmailTextField.text, !contactEmail.isEmpty else {

            showAlert(message: "Please fill all fields")
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let newPost = SkillPost(context: context)
        newPost.title = title
        newPost.postDescription = postDescription
        newPost.category = category
        newPost.availability = availability
        newPost.contactEmail = contactEmail
        newPost.createdAt = Date()

        do {
            try context.save()
            print("Skill post saved successfully")
            dismiss(animated: true)
        } catch {
            print("Failed to save skill post: \(error)")
            showAlert(message: "Could not save skill post")
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
