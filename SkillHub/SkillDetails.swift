//
//  SkillDetails.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-06-08.
//

import Foundation
import UIKit

class SkillDetailsViewController: UIViewController {

    @IBOutlet weak var skillTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var availabilityLabel: UILabel!

    var skillData: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = ""

        skillTitleLabel.text = skillData["title"]

        let posterName = skillData["name"] ?? "Unknown"

        let icon = NSTextAttachment()
        icon.image = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.secondaryLabel)
        icon.bounds = CGRect(
            x: 0,
            y: -3,
            width: 16,
            height: 16
        )

        let text = NSMutableAttributedString(
            attachment: icon
        )

        text.append(
            NSAttributedString(
                string: "  Posted by: ",
                attributes: [
                    .font: UIFont.systemFont(
                        ofSize: 15,
                        weight: .medium
                    ),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
        )

        text.append(
            NSAttributedString(
                string: posterName,
                attributes: [
                    .font: UIFont.systemFont(
                        ofSize: 15,
                        weight: .semibold
                    ),
                    .foregroundColor: UIColor.label
                ]
            )
        )

        nameLabel.attributedText = text
        descriptionTextView.text = skillData["description"]
        availabilityLabel.text = skillData["availability"]
    }

    @IBAction func sendSkillRequestTapped(_ sender: UIButton) {
        guard UserDefaults.standard.object(forKey: "id") != nil else {
            showAlert(
                message: "No signed-in account was found."
            )
            return
        }

        let requesterId = UserDefaults.standard.integer(
            forKey: "id"
        )

        guard requesterId != 0 else {
            showAlert(
                message: "Your user ID is missing. Please log in again."
            )
            return
        }

        guard let posterIdString = skillData["poster_id"],
              let posterId = Int(posterIdString)
        else {
            showAlert(
                message: "The skill poster information is missing."
            )
            return
        }

        guard let skillPostIdString = skillData["id"],
              let skillPostId = Int(skillPostIdString)
        else {
            showAlert(
                message: "The skill post information is missing."
            )
            return
        }

        if requesterId == posterId {
            showAlert(
                message: "You cannot send a request for your own skill post."
            )
            return
        }

        let skillTitle = skillData["title"] ?? "Untitled Skill"

        sender.isEnabled = false

        Task {
            let notificationCreated = await addNotification(
                user_id: posterId,
                message: "Please approve or decline this request.",
                type: "skill_request",
                skillTitle: skillTitle,
                skillPostId: skillPostId,
                requesterId: requesterId,
                status: "pending"
            )

            await MainActor.run {
                sender.isEnabled = true

                if notificationCreated {
                    let alert = UIAlertController(
                        title: "Request Sent",
                        message: "Your skill request has been sent successfully.",
                        preferredStyle: .alert
                    )

                    alert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default
                        )
                    )

                    self.present(
                        alert,
                        animated: true
                    )
                } else {
                    self.showAlert(
                        message: "Failed to send the skill request. Please try again."
                    )
                }
            }
        }
    }

    private func showAlert(message: String) {
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

        present(
            alert,
            animated: true
        )
    }
}
