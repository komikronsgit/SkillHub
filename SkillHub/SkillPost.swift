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
        guard let title = titleTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty,
              
              let postDescription = descriptionTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !postDescription.isEmpty,
              
              let category = categoryTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !category.isEmpty,
              
              let availability = availabilityTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !availability.isEmpty,
              
              let contactEmail = contactEmailTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !contactEmail.isEmpty
        else {
            showAlert(message: "Please fill all fields.")
            return
        }
        
        guard UserDefaults.standard.object(forKey: "id") != nil else {
            showAlert(message: "No signed-in account was found.")
            return
        }
        
        let posterId = UserDefaults.standard.integer(forKey: "id")
        
        guard posterId != 0 else {
            showAlert(message: "User ID is missing. Please log out and log in again.")
            return
        }
        
        sender.isEnabled = false
        
        Task {
            let success = await addSkillPost(
                title: title,
                category: category,
                description: postDescription,
                availability: availability,
                contact_email: contactEmail,
                poster_id: posterId
            )
            
            await MainActor.run {
                sender.isEnabled = true
                
                if success {
                    let alert = UIAlertController(
                        title: "Skill Posted",
                        message: "Your skill post has been created successfully.",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default
                        ) { [weak self] _ in
                            guard let self = self else {
                                return
                            }
                            
                            if let navigationController = self.navigationController,
                               navigationController.viewControllers.count > 1 {
                                navigationController.popViewController(animated: true)
                            } else {
                                self.dismiss(animated: true)
                            }
                        }
                    )
                    
                    self.present(alert, animated: true)
                    
                } else {
                    self.showAlert(
                        message: "Your skill post could not be created. Please check your connection and try again."
                    )
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
