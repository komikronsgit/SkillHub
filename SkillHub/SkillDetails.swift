//
//  SkillDetails.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-06-08.
//
import Foundation
import UIKit
import MessageUI

class SkillDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    let emailSubject = "Skill Request"
    let emailBody = "Hello,\n\nI am interested in your skill listing.\n\nThank you."

    @IBOutlet weak var skillTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var availabilityLabel: UILabel!

    var skillData: [String:String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = ""

        skillTitleLabel.text = skillData["title"]

        let posterName = skillData["name"] ?? "Unknown"

        let icon = NSTextAttachment()
        icon.image = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.secondaryLabel)
        icon.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)

        let text = NSMutableAttributedString(attachment: icon)

        text.append(NSAttributedString(
            string: "  Posted by: ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ]
        ))

        text.append(NSAttributedString(
            string: posterName,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        ))

        nameLabel.attributedText = text

        descriptionTextView.text = skillData["description"]
        availabilityLabel.text = skillData["availability"]
    }

    @IBAction func sendSkillRequestTapped(_ sender: UIButton) {
        Task {
            let requesterId = UserDefaults.standard.integer(forKey: "id")
            let toEmail = skillData["contactEmail"] ?? ""
            let skillTitle = skillData["title"] ?? "Untitled Skill"

            let user = await getUserById(id: requesterId)
            let fromEmail = user.indices.contains(1) ? user[1] : ""

            guard let posterIdString = skillData["poster_id"],
                  let posterId = Int(posterIdString) else {
                print("❌ poster_id missing")
                return
            }

            guard let skillPostIdString = skillData["id"],
                  let skillPostId = Int(skillPostIdString) else {
                print("❌ Skill post ID missing")
                return
            }

            await addNotification(
                user_id: posterId,
                message: "Please approve or decline this request.",
                type: "skill_request",
                skillTitle: skillTitle,
                skillPostId: skillPostId,
                requesterId: requesterId,
                status: "pending"
            )

            await MainActor.run {
                self.showMailComposer(
                    toEmail: toEmail,
                    FromEmail: fromEmail
                )
            }
        }
    }
    
    private func showMailComposer(toEmail: String, FromEmail: String) {
        guard MFMailComposeViewController.canSendMail() else {
            print("cant send mail")
            return
        }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setSubject(emailSubject)
        composer.setMessageBody(emailBody, isHTML: false)
        composer.setToRecipients([toEmail])
        composer.setPreferredSendingEmailAddress(FromEmail)

        present(composer, animated: true)
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: (any Error)?
    ) {
        if let error = error {
            print("email sent with the error: \(error)")
        }

        controller.dismiss(animated: true)
    }
}
