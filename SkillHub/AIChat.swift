//
//  AIChat.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-05-29.
//

import Foundation
import UIKit

class AIChatViewController: UIViewController {

    // MARK: - UI Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    // MARK: - Data
    var messages: [ChatMessage] = []

    var fileText: String?
    var initialPrompt: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupUI()

        // If coming from AI Tab VC (quick actions)
        if let prompt = initialPrompt {
            sendToAI(prompt: prompt, isUserMessage: true)
        }
    }

    // MARK: - Setup
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorStyle = .none
    }

    func setupUI() {
        messageTextField.placeholder = "Type a message..."
    }

    // MARK: - Send Button
    @IBAction func sendButtonTapped(_ sender: UIButton) {

        guard let text = messageTextField.text, !text.isEmpty else {
            showAlert("Please enter a message")
            return
        }

        messageTextField.text = ""

        handleUserInput(text)
    }

    // MARK: - Core Logic
    func handleUserInput(_ text: String) {

        // 1. Add user message
        messages.append(ChatMessage(text: text, isUser: true))
        tableView.reloadData()
        scrollToBottom()

        // 2. Build prompt logic
        var prompt = ""

        if let fileText = fileText, !fileText.isEmpty {
            prompt = """
            Use the file content and user question.

            FILE:
            \(fileText)

            QUESTION:
            \(text)
            """
        } else {
            prompt = text
        }

        // 3. Send to AI
        sendToAI(prompt: prompt, isUserMessage: false)
    }

    // MARK: - OpenAI Call
    func sendToAI(prompt: String, isUserMessage: Bool) {

        OpenAIManager.shared.sendMessage(prompt: prompt) { result in

            DispatchQueue.main.async {

                switch result {

                case .success(let response):

                    self.messages.append(
                        ChatMessage(text: response, isUser: false)
                    )

                    self.tableView.reloadData()
                    self.scrollToBottom()

                case .failure(let error):

                    self.messages.append(
                        ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false)
                    )

                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        }
    }

    // MARK: - Helpers
    func scrollToBottom() {
        let index = IndexPath(row: messages.count - 1, section: 0)
        if index.row >= 0 {
            tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "SkillHub AI", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView
extension AIChatViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]

        let cell = UITableViewCell()

        cell.textLabel?.text = message.text
        cell.textLabel?.numberOfLines = 0

        // Simple chat styling
        cell.textLabel?.textAlignment = message.isUser ? .right : .left

        cell.backgroundColor = message.isUser ? UIColor.systemBlue.withAlphaComponent(0.2)
                                              : UIColor.systemGray6

        return cell
    }
}
