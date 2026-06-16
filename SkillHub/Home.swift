//
//  Home.swift
//  SkillHub
//
//  Created by Tochukwu Okoye on 2026-05-25.
//

import Foundation
import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var notifications: [[String: String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let username = UserDefaults.standard.string(forKey: "username")

        nameLabel.text = username
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 145
        
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNotifications()
    }
    
    func fetchNotifications() {
        Task {
            let id = UserDefaults.standard.integer(forKey: "id")
            
            let notificationStrings = await getNotificationsByUserId(id: id)

            await MainActor.run {
                self.notifications = notificationStrings
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = notifications[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "recentActivity",
            for: indexPath
        )

        var content = cell.defaultContentConfiguration()

        let time = post["time"] ?? "Unknown time"
        let message = post["message"] ?? "No message"

        content.text = message
        content.secondaryText = time

        content.textProperties.font = UIFont.boldSystemFont(ofSize: 20)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator

        return cell
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
