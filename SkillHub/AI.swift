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

    @IBOutlet weak var uploadFileButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!

    var selectedFileURL: URL?
    var selectedFileText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        uploadFileButton.setTitle("No file selected", for: .normal)

        resultTextView.text = "Upload a file to begin..."
        resultTextView.isEditable = false
    }

    // MARK: - Upload File
    @IBAction func uploadNotesTapped(_ sender: UIButton) {

        let supportedTypes: [UTType] = [
            .pdf,
            .plainText,
            UTType(filenameExtension: "doc")!,
            UTType(filenameExtension: "docx")!
        ]

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    // MARK: - QUICK ACTION: SUMMARIZE
    @IBAction func summarizeTapped(_ sender: UIButton) {

        let prompt: String

        if selectedFileText.isEmpty {
            prompt = "Ask the user what they want to summarize."
        } else {
            prompt = """
            Summarize the following content in a simple and clear way:

            \(selectedFileText)
            """
        }

        openChat(prompt: prompt)
    }

    // MARK: - QUICK ACTION: EXPLAIN
    @IBAction func explainTapped(_ sender: UIButton) {

        let prompt: String

        if selectedFileText.isEmpty {
            prompt = "Ask the user what they want explained."
        } else {
            prompt = """
            Explain this in simple terms so a student can understand:

            \(selectedFileText)
            """
        }

        openChat(prompt: prompt)
    }

    // MARK: - QUICK ACTION: QUIZ
    @IBAction func quizTapped(_ sender: UIButton) {

        let prompt: String

        if selectedFileText.isEmpty {
            prompt = "Ask the user what type of quiz they want generated."
        } else {
            prompt = """
            Generate a quiz based on this content:

            - 5 multiple choice questions
            - 3 true/false questions
            - Include answers at the end

            Content:
            \(selectedFileText)
            """
        }

        openChat(prompt: prompt)
    }

    // MARK: - OPEN CHAT VC (CENTRAL NAVIGATION)
    @IBAction func openChatTapped(_ sender: UIButton) {
        openChat(prompt: "User started chat")
    }

    // MARK: - NAVIGATION FUNCTION (IMPORTANT)
    private func openChat(prompt: String) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let chatVC = storyboard.instantiateViewController(withIdentifier: "aichat") as? AIChatViewController else {
            print("❌ AIChatViewController not found. Check Storyboard ID = aichat")
            return
        }

        chatVC.initialPrompt = prompt
        chatVC.fileText = selectedFileText

        if let nav = self.navigationController {
            nav.pushViewController(chatVC, animated: true)
        } else {
            present(chatVC, animated: true)
        }
    }

    // MARK: - FILE PICKER RESULT
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        guard let fileURL = urls.first else { return }

        selectedFileURL = fileURL
        uploadFileButton.setTitle(fileURL.lastPathComponent, for: .normal)

        loadTextFromFile(fileURL)

        resultTextView.text = "File uploaded successfully. You can now use AI actions."
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker cancelled")
    }

    // MARK: - FILE READING
    private func loadTextFromFile(_ fileURL: URL) {

        selectedFileText = ""

        let canAccess = fileURL.startAccessingSecurityScopedResource()

        defer {
            if canAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        let fileExtension = fileURL.pathExtension.lowercased()

        switch fileExtension {

        case "txt":
            loadTXT(from: fileURL)

        case "pdf":
            loadPDF(from: fileURL)

        case "doc", "docx":
            loadWordFile(from: fileURL)

        default:
            resultTextView.text = "Unsupported file type."
        }
    }

    private func loadTXT(from fileURL: URL) {
        do {
            selectedFileText = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            resultTextView.text = "Could not read TXT file."
        }
    }

    private func loadPDF(from fileURL: URL) {

        guard let pdfDocument = PDFDocument(url: fileURL) else {
            resultTextView.text = "Could not open PDF."
            return
        }

        var text = ""

        for i in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: i),
               let pageText = page.string {
                text += pageText + "\n"
            }
        }

        selectedFileText = text
    }

    private func loadWordFile(from fileURL: URL) {
        do {
            selectedFileText = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            resultTextView.text = "DOC/DOCX requires better parsing (we will improve later)."
        }
    }
}
