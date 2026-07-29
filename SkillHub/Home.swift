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

        loadUserName()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground

        fetchNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadUserName()
        fetchNotifications()
    }


    func loadUserName() {
        Task {
            let userId = UserDefaults.standard.integer(forKey: "id")
            let user = await getUserById(id: userId)

            let userName: String

            if user.indices.contains(0), !user[0].isEmpty {
                userName = user[0]
            } else {
                userName = "User"
            }

            await MainActor.run {
                self.nameLabel.text = "Welcome Back, \(userName)"
            }
        }
    }
  
    func fetchNotifications() {
        Task {
            let id = UserDefaults.standard.integer(forKey: "id")
            let data = await getNotificationsByUserId(id: id)

            await MainActor.run {
                self.notifications = data
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let notification = notifications[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "recentActivity",
            for: indexPath
        )

        var content = cell.defaultContentConfiguration()

        let type = notification["type"] ?? "general"
        let status = notification["status"] ?? "info"
        let skillTitle = notification["skill_title"] ?? ""
        let message = notification["message"] ?? "Notification"
        let time = notification["time"] ?? ""

        if type == "skill_request" {
            if status == "approved" {
                content.text = "✅ Skill Request Approved"
                content.secondaryText = """
                Skill: \(skillTitle)
                You approved this request.
                \(time)
                """
            } else if status == "declined" {
                content.text = "❌ Skill Request Declined"
                content.secondaryText = """
                Skill: \(skillTitle)
                You declined this request.
                \(time)
                """
            } else {
                content.text = "✨ New Skill Request"
                content.secondaryText = """
                Skill: \(skillTitle)
                Swipe to approve or decline
                \(time)
                """
            }
        } else if type == "skill_decision" {
            if status == "approved" {
                content.text = "✅ Request Approved"
            } else if status == "declined" {
                content.text = "❌ Request Declined"
            } else {
                content.text = "🔔 Request Update"
            }

            content.secondaryText = """
            Skill: \(skillTitle)
            \(message)
            \(time)
            """
        } else if type == "profile_update" {
            content.text = "👤 Profile Updated"
            content.secondaryText = """
            \(message)
            \(time)
            """
        } else {
            content.text = "🔔 Notification"
            content.secondaryText = """
            \(message)
            \(time)
            """
        }

        content.textProperties.font = UIFont.boldSystemFont(ofSize: 18)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 14)
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.selectionStyle = .default
        cell.backgroundColor = .systemBackground
        cell.contentView.backgroundColor = .systemBackground

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]

        guard notification["type"] == "skill_request",
              notification["status"] == "pending" else {
            return
        }

        let alert = UIAlertController(
            title: "Skill Request",
            message: "Approve or decline this request?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Approve", style: .default) { _ in
            self.handleSkillRequest(notification: notification, status: "approved")
        })

        alert.addAction(UIAlertAction(title: "Decline", style: .destructive) { _ in
            self.handleSkillRequest(notification: notification, status: "declined")
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    func handleSkillRequest(
        notification: [String: String],
        status: String
    ) {
        Task {
            let skillTitle =
                notification["skill_title"] ?? "Requested skill"

            guard let requesterString = notification["requester_id"],
                  let requesterId = Int(requesterString) else {
                await MainActor.run {
                    self.showAlert(
                        title: "Request Failed",
                        message: "Requester information is missing."
                    )
                }
                return
            }

            guard let skillPostString = notification["skill_post_id"],
                  let skillPostId = Int(skillPostString) else {
                await MainActor.run {
                    self.showAlert(
                        title: "Request Failed",
                        message: "Skill post information is missing."
                    )
                }
                return
            }

            guard let notificationId = notification["id"] else {
                await MainActor.run {
                    self.showAlert(
                        title: "Request Failed",
                        message: "Notification information is missing."
                    )
                }
                return
            }

            let posterId = UserDefaults.standard.integer(forKey: "id")

            if status == "approved" {
                let conversationId = await createOrGetConversation(
                    skillPostId: skillPostId,
                    requesterId: requesterId,
                    posterId: posterId
                )

                guard conversationId != nil else {
                    await MainActor.run {
                        self.showAlert(
                            title: "Approval Failed",
                            message: "The conversation could not be created."
                        )
                    }
                    return
                }
            }

            let decisionMessage: String

            if status == "approved" {
                decisionMessage =
                    "Your request for \(skillTitle) was approved. You can now start messaging."
            } else {
                decisionMessage =
                    "Your request for \(skillTitle) was declined."
            }

            let decisionNotificationCreated = await addNotification(
                user_id: requesterId,
                message: decisionMessage,
                type: "skill_decision",
                skillTitle: skillTitle,
                skillPostId: skillPostId,
                requesterId: nil,
                status: status
            )

            guard decisionNotificationCreated else {
                await MainActor.run {
                    self.showAlert(
                        title: "Request Failed",
                        message: "The requester could not be notified."
                    )
                }
                return
            }

            let statusUpdated = await updateNotificationStatus(
                id: notificationId,
                status: status
            )

            await MainActor.run {
                if statusUpdated {
                    self.fetchNotifications()

                    self.showAlert(
                        title: status == "approved"
                            ? "Request Approved"
                            : "Request Declined",
                        message: status == "approved"
                            ? "The request was approved successfully."
                            : "The request was declined successfully."
                    )
                } else {
                    self.showAlert(
                        title: "Update Failed",
                        message: "The notification status could not be updated."
                    )
                }
            }
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let notification = notifications[indexPath.row]

        let approve = UIContextualAction(style: .normal, title: "Approve") { _, _, completion in
            self.handleSkillRequest(notification: notification, status: "approved")
            completion(true)
        }
        approve.backgroundColor = .systemGreen

        let decline = UIContextualAction(style: .destructive, title: "Decline") { _, _, completion in
            self.handleSkillRequest(notification: notification, status: "declined")
            completion(true)
        }

        let remove = UIContextualAction(style: .destructive, title: "Remove") { _, _, completion in
            Task {
                guard let id = notification["id"] else {
                    await MainActor.run {
                        completion(false)
                    }
                    return
                }

                let deleted = await deleteNotification(id: id)

                await MainActor.run {
                    if deleted {
                        self.notifications.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        completion(true)
                    } else {
                        let alert = UIAlertController(
                            title: "Delete Failed",
                            message: "Unable to delete the notification. Please try again.",
                            preferredStyle: .alert
                        )

                        alert.addAction(
                            UIAlertAction(
                                title: "OK",
                                style: .default
                            )
                        )

                        self.present(alert, animated: true)
                        completion(false)
                    }
                }
            }
        }

        if notification["type"] == "skill_request",
           notification["status"] == "pending" {
            return UISwipeActionsConfiguration(actions: [decline, approve, remove])
        }

        return UISwipeActionsConfiguration(actions: [remove])
    }
    @IBAction func marketplaceTapped(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }

    @IBAction func aiTapped(_ sender: Any) {
        tabBarController?.selectedIndex = 2
    }

    private func showAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(alert, animated: true)
    }

}
    
