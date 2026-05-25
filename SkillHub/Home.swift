//
//  Home.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-05-25.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let username = UserDefaults.standard.string(forKey: "username")

        nameLabel.text = username
        }
    @IBAction func marketplaceTapped(_ sender: Any) {
        print("Marketplace tapped")

        if let tabBar = self.tabBarController {
            tabBar.selectedIndex = 1
            print("Changed to Marketplace")
        } else {
            print("tabBarController is nil")
        }
    }

    @IBAction func aiTapped(_ sender: Any) {
        print("AI tapped")

        if let tabBar = self.tabBarController {
            tabBar.selectedIndex = 2
            print("Changed to AI")
        } else {
            print("tabBarController is nil")
        }
    }
}
