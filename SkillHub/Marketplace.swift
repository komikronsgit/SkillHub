//
//  Marketplace.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-05-25.
//

import UIKit
import CoreData

class MarketplaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var skillPosts: [[String: String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchSkillPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSkillPosts()
    }

    func fetchSkillPosts() {
        Task {
            let posts = await getAllSkillPosts()

            await MainActor.run {
                self.skillPosts = posts
                self.tableView.reloadData()
                print("Fetched \(posts.count) skill posts")
            }
        }
    }

    @IBAction func addSkillTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "CreateSkillPost")
        createVC.modalPresentationStyle = .fullScreen
        present(createVC, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skillPosts.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let post = skillPosts[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "listOfSkills",
            for: indexPath
        )

        var content = cell.defaultContentConfiguration()

        let title = post["title"] ?? "Untitled Skill"
        let category = post["category"] ?? "No category"
        let availability = post["availability"] ?? post["avalibility"] ?? "No availability"
        let description = post["description"] ?? "No description"
        let email = post["contactEmail"] ?? post["contact_email"] ?? "No email"

        content.text = title
        content.secondaryText = """
        Category: \(category)
        Availability: \(availability)
        Description: \(description)
        Contact: \(email)
        """

        content.textProperties.font = UIFont.boldSystemFont(ofSize: 20)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 15)
        content.secondaryTextProperties.color = .darkGray

        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }
}
