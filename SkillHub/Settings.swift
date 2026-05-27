//
//  Settings.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-26.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBAction func editProfileTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "EditProfile")
        createVC.modalPresentationStyle = .fullScreen
        present(createVC, animated: true)
    }
    
    @IBAction func privacySecurityTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "privacy")
        createVC.modalPresentationStyle = .fullScreen
        present(createVC, animated: true)
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "username")
        UserDefaults.standard.set(nil, forKey: "userEmail")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "SignIn")
        createVC.modalPresentationStyle = .fullScreen
        present(createVC, animated: true)
    }
}
