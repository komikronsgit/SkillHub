//
//  EditProfile.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-25.
//
import UIKit
import PhotosUI

class EditProfileViewController: UIViewController, PHPickerViewControllerDelegate {

    @IBOutlet weak var profilePicInput: UIButton!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var schoolInput: UITextField!
    @IBOutlet weak var programInput: UITextField!
    @IBOutlet weak var bioInput: UITextField!

    private var selectedImageData: Data?
    private var selectedImagePath: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureProfileButton()
    }

    func configureProfileButton() {
        profilePicInput.imageView?.contentMode = .scaleAspectFill
        profilePicInput.clipsToBounds = true

        profilePicInput.layer.cornerRadius = profilePicInput.bounds.width / 2
        profilePicInput.layer.borderWidth = 2
        profilePicInput.layer.borderColor = UIColor.systemBlue.cgColor
    }

    func loadUserData() {
        Task {
            await updateProfilePic()

            let id = UserDefaults.standard.integer(forKey: "id")
            let user = await getUserById(id: id)

            guard user.count >= 6 else { return }

            await MainActor.run {
                self.nameInput.text = user[0]
                self.emailInput.text = user[1]
                self.bioInput.text = user[3]
                self.programInput.text = user[4]
                self.schoolInput.text = user[5]
            }
        }
    }

    @IBAction func changePicTapped(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { image, _ in
            guard let selectedImage = image as? UIImage,
                  let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                return
            }

            let id = UserDefaults.standard.integer(forKey: "id")
            let path = "\(id)_\(Int(Date().timeIntervalSince1970)).jpg"

            self.selectedImageData = imageData
            self.selectedImagePath = path

            DispatchQueue.main.async {
                self.profilePicInput.setImage(selectedImage, for: .normal)
                self.configureProfileButton()
            }
        }
    }

    @IBAction func saveEdit(_ sender: UIButton) {
        Task {
            let id = UserDefaults.standard.integer(forKey: "id")

            let name = nameInput.text ?? ""
            let email = emailInput.text ?? ""
            let school = schoolInput.text ?? ""
            let program = programInput.text ?? ""
            let aboutMe = bioInput.text ?? ""

            if let imageData = selectedImageData {
                let path = selectedImagePath ?? "\(id)_\(Int(Date().timeIntervalSince1970)).jpg"
                await addOrUpdateProfilePic(path: path, data: imageData)
            }

            await updateUserById(
                id: id,
                name: name,
                email: email,
                about_me: aboutMe,
                program: program,
                school: school
            )

            await MainActor.run {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func updateProfilePic() async {
        let imageData = await getProfilePic()

        await MainActor.run {
            if let image = UIImage(data: imageData) {
                self.profilePicInput.setImage(image, for: .normal)
            } else {
                self.profilePicInput.setImage(
                    UIImage(systemName: "person.fill"),
                    for: .normal
                )
            }

            self.configureProfileButton()
        }
    }
}
