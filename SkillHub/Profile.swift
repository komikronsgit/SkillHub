//
//  Profile.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-25.
//
import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var programLable: UILabel!
    @IBOutlet weak var schoolLable: UILabel!
    @IBOutlet weak var aboutMeLable: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureProfileImage()
        configureAboutMe()
        loadProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        configureProfileImage()
    }

    func configureProfileImage() {
        profilePicImage.contentMode = .scaleAspectFill
        profilePicImage.clipsToBounds = true
        profilePicImage.layer.cornerRadius = profilePicImage.bounds.width / 2
        profilePicImage.layer.borderWidth = 2
        profilePicImage.layer.borderColor = UIColor.systemBlue.cgColor
    }

    func configureAboutMe() {
        aboutMeLable.isEditable = false
        aboutMeLable.isScrollEnabled = true
        aboutMeLable.layer.cornerRadius = 12
        aboutMeLable.textContainerInset = UIEdgeInsets(
            top: 12,
            left: 10,
            bottom: 12,
            right: 10
        )
    }

    func loadProfile() {
        Task {
            let imageData = await getProfilePic()

            let id = UserDefaults.standard.integer(forKey: "id")
            let user = await getUserById(id: id)

            await MainActor.run {
                if let image = UIImage(data: imageData) {
                    self.profilePicImage.image = image
                } else {
                    self.profilePicImage.image = UIImage(systemName: "person.fill")
                }

                if user.count >= 6 {
                    self.nameLable.text = user[0]
                    self.aboutMeLable.text = user[3]
                    self.programLable.text = user[4]
                    self.schoolLable.text = user[5]
                }

                self.configureProfileImage()
            }
        }
    }

    @IBAction func openEditProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let settingsVC = storyboard.instantiateViewController(
            withIdentifier: "settings"
        )

        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
