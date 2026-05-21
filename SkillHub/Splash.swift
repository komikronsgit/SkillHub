//
//  Splash.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-12.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show app icon
        logoImageView.image = UIImage(named: "skillhub_icon")
    }

    @IBAction func getStartedTapped(_ sender: UIButton) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignIn")

        navigationController?.pushViewController(signInVC, animated: true)
    }
}
