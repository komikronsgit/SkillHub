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
        configureNavigationBar()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
    }

   
    func configureNavigationBar() {

        navigationController?.setNavigationBarHidden(false, animated: false)

  
        self.title = ""
        self.navigationItem.title = ""

        self.navigationItem.titleView = UIView()

        self.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
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

        let posterId = UserDefaults.standard.integer(forKey: "id")

        if posterId == 0 {
            showAlert(message: "User ID missing. Please log out and log in again.")
            print("ERROR: posterId is 0")
            return
        }

        Task {
            await addSkillPost(
                title: title,
                category: category,
                description: postDescription,
                availability: availability,
                contact_email: contactEmail,
                poster_id: posterId
            )

            await MainActor.run {
                print("Skill post submitted")

                if let navigationController = self.navigationController,
                   navigationController.viewControllers.count > 1 {
                    navigationController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(
            title: "SkillHub",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }
} 
