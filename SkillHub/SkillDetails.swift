//
//  SkillDetails.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-06-08.
//

import Foundation
import UIKit
import MessageUI

class SkillDetailsViewController:
UIViewController,
MFMailComposeViewControllerDelegate {

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

    @IBAction func sendSkillRequestTapped(
        _ sender: UIButton
    ) {

        guard MFMailComposeViewController.canSendMail()
        else { return }

        let recipient =
            skillData["contactEmail"] ?? ""

        let composer =
            MFMailComposeViewController()

        composer.mailComposeDelegate = self

        composer.setToRecipients([recipient])

        composer.setSubject(
            "Skill Request"
        )

        composer.setMessageBody(
            """
            Hello,

            I am interested in your skill listing.

            Thank you.
            """,
            isHTML: false
        )

        present(composer, animated: true)
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        dismiss(animated: true)
    }
}
