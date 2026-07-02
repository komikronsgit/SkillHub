//
//  AI.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-05-29.
//

import UIKit
import UniformTypeIdentifiers
import PDFKit

class AIViewController: UIViewController, UIDocumentPickerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var uploadFileButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    // MARK: - Data
    var selectedFileURL: URL?
    var selectedFileText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        uploadFileButton.setTitle("No file selected", for: .normal)

        resultTextView.text = """
        Upload a file or type a message...
        Use only PDF or TXT
        """
        resultTextView.isEditable = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Upload File
    @IBAction func uploadNotesTapped(_ sender: UIButton) {

        let supportedTypes: [UTType] = [
            .pdf,
            .plainText
        ]

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    // MARK: - QUICK ACTIONS

    @IBAction func summarizeTapped(_ sender: UIButton) {

        let prompt: String

        if selectedFileText.isEmpty {
            prompt = "Ask the user what they want to summarize."
        } else {
            prompt = """
            Summarize this content clearly:

            \(String(selectedFileText.prefix(10000)))
            """
        }

        openChat(prompt: prompt)
    }

    @IBAction func explainTapped(_ sender: UIButton) {

        let prompt: String

        if selectedFileText.isEmpty {
            prompt = "Ask the user what they want explained."
        } else {
            prompt = """
            Explain this in simple terms:

            \(String(selectedFileText.prefix(10000)))
            """
        }

        openChat(prompt: prompt)
    }

    @IBAction func quizTapped(_ sender: UIButton) {

        let prompt: String

        if selectedFileText.isEmpty {
            prompt = "Ask the user what type of quiz they want."
        } else {
            prompt = """
            Generate a quiz:

            - 5 multiple choice
            - 3 true/false
            - Include answers

            Content:
            \(String(selectedFileText.prefix(10000)))
            """
        }

        openChat(prompt: prompt)
    }

    // MARK: - SEND BUTTON (TEXT FIELD LOGIC)
    @IBAction func sendTapped(_ sender: UIButton) {

        let userText = promptTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if userText.isEmpty && selectedFileText.isEmpty {

            let alert = UIAlertController(
                title: "SkillHub AI",
                message: "No text provided.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        var prompt = ""

        if !selectedFileText.isEmpty && !userText.isEmpty {

            prompt = """
            Use the file and answer the question.

            FILE:
            \(String(selectedFileText.prefix(10000)))

            QUESTION:
            \(userText)
            """

        } else if !selectedFileText.isEmpty {

            prompt = """
            Explain this file:

            \(String(selectedFileText.prefix(10000)))
            """

        } else {

            prompt = userText
        }

        openChat(prompt: prompt)
    }

    // MARK: - NAVIGATION
    private func openChat(prompt: String) {

        guard let chatVC = storyboard?.instantiateViewController(withIdentifier: "aichat") as? AIChatViewController else {
            print("AIChatViewController not found")
            return
        }

        chatVC.initialPrompt = prompt
        chatVC.fileText = selectedFileText

        navigationController?.pushViewController(chatVC, animated: true)
    }

    // MARK: - FILE PICKER
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        guard let fileURL = urls.first else { return }

        selectedFileURL = fileURL
        uploadFileButton.setTitle(fileURL.lastPathComponent, for: .normal)

        loadTextFromFile(fileURL)

        resultTextView.text = "File uploaded successfully."
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}

    // MARK: - FILE LOADING
    private func loadTextFromFile(_ fileURL: URL) {

        selectedFileText = ""

        let canAccess = fileURL.startAccessingSecurityScopedResource()

        defer {
            if canAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        let ext = fileURL.pathExtension.lowercased()

        switch ext {

        case "txt":
            loadTXT(fileURL)

        case "pdf":
            loadPDF(fileURL)

        default:
            resultTextView.text = "Unsupported file type."
        }
    }

    private func loadTXT(_ fileURL: URL) {
        do {
            selectedFileText = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            resultTextView.text = "Could not read TXT file."
        }
    }

    private func loadPDF(_ fileURL: URL) {

        guard let pdf = PDFDocument(url: fileURL) else {
            resultTextView.text = "Could not open PDF."
            return
        }

        var text = ""

        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i) {
                text += page.string ?? ""
            }
        }

        selectedFileText = text
    }
}
