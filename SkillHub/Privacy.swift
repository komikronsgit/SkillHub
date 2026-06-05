//
//  Privacy.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-26.
//

import Foundation
import UIKit
import CoreData

class PrivacyViewController: UIViewController {
    
    @IBAction func changePasswordTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "change")
        self.navigationController?.pushViewController(createVC, animated: true)
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        Task {
            let id: Int = UserDefaults.standard.integer(forKey: "id")
            
            await deleteUserById(id: id)
            
            UserDefaults.standard.set(nil, forKey: "id")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewController(withIdentifier: "SignIn")
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
        }
    }
}
