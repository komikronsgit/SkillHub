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

        skillTitleLabel.text = skillData["title"]

        nameLabel.text =
            skillData["name"] ??
            "Unknown"

        descriptionTextView.text =
            skillData["description"]

        availabilityLabel.text =
            skillData["availability"]
    }

    @IBAction func sendSkillRequestTapped(_ sender: UIButton) {
        Task {
            let toEmail = skillData["contactEmail"] ?? ""
            let fromEmail = await getUserById(id: UserDefaults.standard.integer(forKey: "id"))[1]
            showMailComposer(toEmail: toEmail, FromEmail: fromEmail)
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
        
        present(composer, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        if let error = error {
            print("email sent with the error: \(error)")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
