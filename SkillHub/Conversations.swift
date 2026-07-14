//
//  Conversations.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-07-13.
//

import UIKit
import Supabase

class ChatViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var conversationId: Int?
    var chatTitle: String = "Chat"

    private var messages: [ChatMessageModel] = []
    private var realtimeTask: Task<Void, Never>?

    private let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://eopbyxioxjnyeyxcuikg.supabase.co"
        )!,
        supabaseKey: Config.supabaseAnonKey
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = chatTitle

        configureTableView()
        configureMessageInput()

        guard conversationId != nil else {
            print("❌ conversationId was not passed to chat screen")
            sendButton.isEnabled = false
            return
        }

        loadMessages()
        subscribeToMessages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        realtimeTask?.cancel()
        realtimeTask = nil
    }

    // MARK: - UI Configuration

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.backgroundColor = .systemBackground

        tableView.register(
            MessageBubbleCell.self,
            forCellReuseIdentifier: MessageBubbleCell.identifier
        )
    }

    private func configureMessageInput() {
        messageTextField.delegate = self
        messageTextField.placeholder = "Type a message..."
        messageTextField.returnKeyType = .send
        messageTextField.backgroundColor = .secondarySystemBackground

        messageTextField.layer.cornerRadius = 18
        messageTextField.layer.masksToBounds = true

        let leftPadding = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 14,
                height: 1
            )
        )

        let rightPadding = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 14,
                height: 1
            )
        )

        messageTextField.leftView = leftPadding
        messageTextField.leftViewMode = .always
        messageTextField.rightView = rightPadding
        messageTextField.rightViewMode = .always

        sendButton.tintColor = .white
    }

    // MARK: - Load Messages

    private func loadMessages() {
        guard let conversationId else {
            return
        }

        Task {
            let loadedMessages = await getMessages(
                conversationId: conversationId
            )

            await MainActor.run {
                self.messages = loadedMessages
                self.tableView.reloadData()
                self.scrollToBottom(animated: false)
            }
        }
    }

    // MARK: - Supabase Realtime

    private func subscribeToMessages() {
        guard let conversationId else {
            return
        }

        let channel = client.channel(
            "conversation-\(conversationId)"
        )

        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "Message",
            filter: .eq(
                "conversation_id",
                value: conversationId
            )
        )

        realtimeTask = Task {
            await channel.subscribe()

            for await _ in insertions {
                if Task.isCancelled {
                    break
                }

                let updatedMessages = await getMessages(
                    conversationId: conversationId
                )

                await MainActor.run {
                    self.messages = updatedMessages
                    self.tableView.reloadData()
                    self.scrollToBottom(animated: true)
                }
            }
        }
    }

    // MARK: - Send Message

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendCurrentMessage()
    }

    private func sendCurrentMessage() {
        guard let conversationId else {
            print("❌ No conversation selected")
            return
        }

        let text = messageTextField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

        guard !text.isEmpty else {
            return
        }

        let currentUserId = UserDefaults.standard.integer(
            forKey: "id"
        )

        messageTextField.text = ""
        sendButton.isEnabled = false

        Task {
            let sent = await sendMessage(
                conversationId: conversationId,
                senderId: currentUserId,
                text: text
            )

            await MainActor.run {
                self.sendButton.isEnabled = true

                if !sent {
                    self.messageTextField.text = text
                    self.showError(
                        message: "The message could not be sent."
                    )
                }
            }

            if sent {
                loadMessages()
            }
        }
    }

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {
        sendCurrentMessage()
        return true
    }

    // MARK: - Table View

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return messages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let message = messages[indexPath.row]

        let currentUserId = UserDefaults.standard.integer(
            forKey: "id"
        )

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell.identifier,
            for: indexPath
        ) as? MessageBubbleCell else {
            return UITableViewCell()
        }

        let isCurrentUser = message.sender_id == currentUserId

        cell.configure(
            message: message.message,
            time: formatTime(message.created_at),
            isCurrentUser: isCurrentUser
        )

        return cell
    }

    // MARK: - Helpers

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else {
            return
        }

        let lastIndexPath = IndexPath(
            row: messages.count - 1,
            section: 0
        )

        tableView.scrollToRow(
            at: lastIndexPath,
            at: .bottom,
            animated: animated
        )
    }

    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Message Error",
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


// MARK: - Message Bubble Cell

final class MessageBubbleCell: UITableViewCell {

    static let identifier = "MessageBubbleCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        bubbleView.clipsToBounds = true

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 11)

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)

        leadingConstraint = bubbleView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 16
        )

        trailingConstraint = bubbleView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -16
        )

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 6
            ),

            bubbleView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -6
            ),

            bubbleView.widthAnchor.constraint(
                lessThanOrEqualTo: contentView.widthAnchor,
                multiplier: 0.75
            ),

            messageLabel.topAnchor.constraint(
                equalTo: bubbleView.topAnchor,
                constant: 10
            ),

            messageLabel.leadingAnchor.constraint(
                equalTo: bubbleView.leadingAnchor,
                constant: 14
            ),

            messageLabel.trailingAnchor.constraint(
                equalTo: bubbleView.trailingAnchor,
                constant: -14
            ),

            timeLabel.topAnchor.constraint(
                equalTo: messageLabel.bottomAnchor,
                constant: 4
            ),

            timeLabel.leadingAnchor.constraint(
                equalTo: messageLabel.leadingAnchor
            ),

            timeLabel.trailingAnchor.constraint(
                equalTo: messageLabel.trailingAnchor
            ),

            timeLabel.bottomAnchor.constraint(
                equalTo: bubbleView.bottomAnchor,
                constant: -8
            )
        ])
    }

    func configure(
        message: String,
        time: String,
        isCurrentUser: Bool
    ) {
        messageLabel.text = message
        timeLabel.text = time

        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        if isCurrentUser {
            trailingConstraint.isActive = true

            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            timeLabel.textColor = UIColor.white.withAlphaComponent(0.75)
            timeLabel.textAlignment = .right
        } else {
            leadingConstraint.isActive = true

            bubbleView.backgroundColor = .secondarySystemBackground
            messageLabel.textColor = .label
            timeLabel.textColor = .secondaryLabel
            timeLabel.textAlignment = .left
        }
    }
}
