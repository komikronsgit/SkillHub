//
//  Marketplace.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-05-25.
//

import UIKit

class MarketplaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var allSkillPosts: [[String: String]] = []
    var skillPosts: [[String: String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 145

        searchBar.delegate = self
        searchBar.showsCancelButton = false

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
                self.allSkillPosts = posts
                self.skillPosts = posts
                self.tableView.reloadData()
                print("Fetched \(posts.count) skill posts")
            }
        }
    }

    @IBAction func addSkillTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let createVC = storyboard.instantiateViewController(
            withIdentifier: "CreateSkillPost"
        )

        if let navigationController = self.navigationController {
            navigationController.pushViewController(createVC, animated: true)
        } else {
            createVC.modalPresentationStyle = .fullScreen
            present(createVC, animated: true)
        }
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return skillPosts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let post = skillPosts[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "listOfSkills",
            for: indexPath
        )

        var content = cell.defaultContentConfiguration()

        let title = post["title"] ?? "Untitled Skill"
        let category = post["category"] ?? "No category"
        let availability = post["availability"] ?? "No availability"
        let description = post["description"] ?? "No description"
        let email = post["contactEmail"] ?? "No email"

        content.text = title
        content.secondaryText = """
        \(category)
        \(availability)
        \(description)
        \(email)
        """

        content.textProperties.font = UIFont.boldSystemFont(ofSize: 20)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedPost = skillPosts[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let detailsVC = storyboard.instantiateViewController(
            withIdentifier: "details"
        ) as? SkillDetailsViewController else {
            return
        }

        detailsVC.skillData = selectedPost

        navigationController?.pushViewController(detailsVC, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { _, _, completion in
            self.showDeleteConfirmation(indexPath: indexPath)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func showDeleteConfirmation(indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Skill",
            message: "Are you sure you want to delete this skill?",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.deleteSkill(at: indexPath)
            }
        )

        present(alert, animated: true)
    }

    func deleteSkill(at indexPath: IndexPath) {
        let post = skillPosts[indexPath.row]

        guard let id = post["id"] else {
            return
        }

        Task {
            await deleteSkillPost(id: id)

            await MainActor.run {
                self.skillPosts.remove(at: indexPath.row)
                self.allSkillPosts.removeAll { $0["id"] == id }

                self.tableView.deleteRows(
                    at: [indexPath],
                    with: .automatic
                )
            }
        }
    }
}

extension MarketplaceViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()

        skillPosts = allSkillPosts
        tableView.reloadData()
    }

    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        let query = searchText
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            skillPosts = allSkillPosts
        } else {
            skillPosts = allSkillPosts.filter { post in
                let title = post["title"]?.lowercased() ?? ""
                let category = post["category"]?.lowercased() ?? ""
                let availability =
                    post["availability"]?.lowercased() ??
                    post["avalibility"]?.lowercased() ??
                    ""
                let description = post["description"]?.lowercased() ?? ""
                let email =
                    post["contactEmail"]?.lowercased() ??
                    post["contact_email"]?.lowercased() ??
                    ""

                return title.contains(query)
                    || category.contains(query)
                    || availability.contains(query)
                    || description.contains(query)
                    || email.contains(query)
            }
        }

        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
}
