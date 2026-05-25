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
}
