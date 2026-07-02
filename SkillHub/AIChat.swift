//
//  AIChat.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-05-29.
//

import Foundation
import UIKit

class AIChatViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    // MARK: - Data
    var messages: [ChatMessage] = []

    var fileText: String?
    var initialPrompt: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        messageTextField.placeholder = "Type a message..."

        guard let prompt = initialPrompt else { return }

        // ONLY send system prompt to AI, NOT display it
        sendToAI(prompt: prompt)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
    }

    // MARK: - Navigation Bar
    func configureNavigationBar() {
        // not hiding full navigator bar to keep back button
        navigationController?.setNavigationBarHidden(false, animated: false)

        // deleting title by giving empty value
        self.title = ""
        self.navigationItem.title = ""

        // precenting Storyboard title
        self.navigationItem.titleView = UIView()

        // preventing large title
        self.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - SEND BUTTON
    @IBAction func sendButtonTapped(_ sender: UIButton) {

        let text = messageTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !text.isEmpty else {
            showAlert("Please enter a message")
            return
        }

        messageTextField.text = ""

        messages.append(ChatMessage(text: text, type: .user))
        tableView.reloadData()
        scrollToBottom()

        handleUserInput(text)
    }

    // MARK: - CHAT LOGIC
    func handleUserInput(_ text: String) {

        var prompt = ""

        if let fileText = fileText, !fileText.isEmpty {

            prompt = """
            Use file + question:

            FILE:
            \(String(fileText.prefix(10000)))

            QUESTION:
            \(text)
            """
        } else {
            prompt = text
        }

        sendToAI(prompt: prompt)
    }

    // MARK: - AI CALL
    func sendToAI(prompt: String) {

        OpenAIManager.shared.sendMessage(prompt: prompt) { result in

            DispatchQueue.main.async {

                switch result {

                case .success(let response):

                    self.messages.append(
                        ChatMessage(text: response, type: .ai)
                    )

                case .failure(let error):

                    self.messages.append(
                        ChatMessage(text: error.localizedDescription, type: .ai)
                    )
                }

                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }

    // MARK: - UI HELPERS
    func scrollToBottom() {

        guard messages.count > 0 else { return }

        let index = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: true)
    }

    func showAlert(_ message: String) {

        let alert = UIAlertController(
            title: "SkillHub AI",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TABLEVIEW
extension AIChatViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]

        let cell = UITableViewCell()
        cell.textLabel?.text = message.text
        cell.textLabel?.numberOfLines = 0

        switch message.type {

        case .user:
            cell.textLabel?.textAlignment = .right
            cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)

        case .ai:
            cell.textLabel?.textAlignment = .left
            cell.backgroundColor = UIColor.systemGray6

        case .system:
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .gray
            cell.backgroundColor = .clear
        }

        return cell
    }
}
