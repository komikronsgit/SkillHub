//
//  Privacy.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-26.
//

import Foundation
import UIKit

class PrivacyViewController: UIViewController {
    
    @IBAction func changePasswordTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "change")
        createVC.modalPresentationStyle = .fullScreen
        present(createVC, animated: true)
    }
}
