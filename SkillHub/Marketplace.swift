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

    var skillPosts: [SkillPost] = []

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
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request: NSFetchRequest<SkillPost> = SkillPost.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            skillPosts = try context.fetch(request)
            tableView.reloadData()
            print("Fetched \(skillPosts.count) skill posts")
        } catch {
            print("Failed to fetch skill posts: \(error)")
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let post = skillPosts[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "listOfSkills",
            for: indexPath
        )

        var content = cell.defaultContentConfiguration()

        content.text = post.title ?? "Untitled Skill"

        let category = post.category ?? "No category"
        let availability = post.availability ?? "No availability"
        let description = post.postDescription ?? ""
        let email = post.contactEmail ?? "No email"

        content.secondaryText = "\(category) • \(availability)\n\(description)\nContact: \(email)"

        cell.contentConfiguration = content

        return cell
    }
}
