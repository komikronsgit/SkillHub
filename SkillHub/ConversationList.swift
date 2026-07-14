//
//  ConversationList.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-07-13.
//

import UIKit

class ConversationListViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    private var conversations: [ConversationModel] = []
    private var userNames: [Int: String] = [:]
    private var skillTitles: [Int: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Chats"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "conversationCell"
        )

        loadConversations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConversations()
    }

    // MARK: - Load Conversations

    private func loadConversations() {
        Task {
            let currentUserId = UserDefaults.standard.integer(
                forKey: "id"
            )

            print("🔎 Chat list user ID: \(currentUserId)")

            let loadedConversations = await getConversationsForUser(
                userId: currentUserId
            )

            let validConversations = loadedConversations.filter {
                $0.requester_id != $0.poster_id
            }

            print("💬 Valid chats found: \(validConversations.count)")

            await MainActor.run {
                self.conversations = validConversations
                self.tableView.reloadData()
            }

            var loadedNames: [Int: String] = [:]
            var loadedTitles: [Int: String] = [:]

            for conversation in validConversations {
                let otherUserId =
                    conversation.requester_id == currentUserId
                    ? conversation.poster_id
                    : conversation.requester_id

                let user = await getUserById(
                    id: otherUserId
                )

                if user.indices.contains(0),
                   !user[0].isEmpty {
                    loadedNames[otherUserId] = user[0]
                } else {
                    loadedNames[otherUserId] = "User"
                }

                let skillTitle = await getSkillPostTitle(
                    skillPostId: conversation.skill_post_id
                )

                loadedTitles[
                    conversation.skill_post_id
                ] = skillTitle
            }

            await MainActor.run {
                self.userNames = loadedNames
                self.skillTitles = loadedTitles
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table View Data Source

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        print("📋 Table rows: \(conversations.count)")
        return conversations.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        print("🧱 Creating conversation cell \(indexPath.row)")

        let conversation = conversations[indexPath.row]

        let currentUserId = UserDefaults.standard.integer(
            forKey: "id"
        )

        let otherUserId =
            conversation.requester_id == currentUserId
            ? conversation.poster_id
            : conversation.requester_id

        let otherUserName =
            userNames[otherUserId] ?? "Loading user..."

        let skillTitle =
            skillTitles[conversation.skill_post_id]
            ?? "Loading skill..."

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "conversationCell",
            for: indexPath
        )

        var content = cell.defaultContentConfiguration()

        content.image = UIImage(
            systemName: "person.circle.fill"
        )

        content.imageProperties.tintColor = .systemBlue

        content.imageProperties.maximumSize = CGSize(
            width: 42,
            height: 42
        )

        content.text = otherUserName
        content.secondaryText = skillTitle

        content.textProperties.font = UIFont.systemFont(
            ofSize: 18,
            weight: .semibold
        )

        content.secondaryTextProperties.font = UIFont.systemFont(
            ofSize: 14
        )

        content.secondaryTextProperties.color = .secondaryLabel

        content.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 12,
            leading: 12,
            bottom: 12,
            trailing: 8
        )

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.backgroundColor = .systemBackground

        return cell
    }

    // MARK: - Open Chat

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        let conversation = conversations[indexPath.row]

        let currentUserId = UserDefaults.standard.integer(
            forKey: "id"
        )

        let otherUserId =
            conversation.requester_id == currentUserId
            ? conversation.poster_id
            : conversation.requester_id

        let otherUserName =
            userNames[otherUserId] ?? "Chat"

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "chat"
        ) as? ChatViewController else {
            print("❌ Chat screen could not be opened")
            return
        }

        chatVC.conversationId = conversation.id
        chatVC.chatTitle = otherUserName

        guard let navigationController = navigationController else {
            print("❌ Conversation list is not inside a navigation controller")
            return
        }

        navigationController.pushViewController(
            chatVC,
            animated: true
        )
    }
}
