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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
    }

    // MARK: - Navigation Bar
    func configureNavigationBar() {
        // Navigation bar는 숨기지 않음
        // 그래야 Back 버튼이 계속 보임
        navigationController?.setNavigationBarHidden(false, animated: false)

        // 가운데 title 제거
        self.title = ""
        self.navigationItem.title = ""

        // Storyboard에서 자동으로 잡힌 title도 안 보이게 막음
        self.navigationItem.titleView = UIView()

        // Large title 방지
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
                avalibility: availability,
                contact_email: contactEmail,
                poster_id: posterId
            )

            await MainActor.run {
                print("Skill post submitted")

                // Push로 들어온 화면이면 이전 화면으로 pop
                if let navigationController = self.navigationController,
                   navigationController.viewControllers.count > 1 {
                    navigationController.popViewController(animated: true)
                } else {
                    // Modal로 열린 경우 fallback
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
