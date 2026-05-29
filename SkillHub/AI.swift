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

        resultTextView.text = "Results will appear here..."
        resultTextView.isEditable = false
        resultTextView.layer.cornerRadius = 12
        resultTextView.layer.borderWidth = 1
        resultTextView.layer.borderColor = UIColor.systemGray4.cgColor
    }

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

    @IBAction func summarizeTapped(_ sender: UIButton) {
        guard !selectedFileText.isEmpty else {
            resultTextView.text = "Please upload a readable file first."
            return
        }

        let sentences = selectedFileText
            .components(separatedBy: ".")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let summary = sentences.prefix(5).joined(separator: ".\n\n")

        resultTextView.text = """
        Summary Notes:

        \(summary).
        """
    }

    @IBAction func explainSimplyTapped(_ sender: UIButton) {
        guard !selectedFileText.isEmpty else {
            resultTextView.text = "Please upload a readable file first."
            return
        }

        resultTextView.text = """
        Simple Explanation:

        \(selectedFileText.prefix(700))
        """
    }

    @IBAction func quizGeneratorTapped(_ sender: UIButton) {
        guard !selectedFileText.isEmpty else {
            resultTextView.text = "Please upload a readable file first."
            return
        }

        let stopWords: Set<String> = [
            "about", "after", "again", "also", "because", "before", "between",
            "could", "every", "first", "from", "have", "into", "more", "other",
            "should", "their", "there", "these", "they", "this", "those", "through",
            "under", "using", "where", "which", "while", "would", "your", "with"
        ]

        let words = selectedFileText
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 4 && !stopWords.contains($0) }

        let keywordCounts = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }

        let keywords = keywordCounts
            .sorted { $0.value > $1.value }
            .map { $0.key.capitalized }
            .prefix(5)

        guard !keywords.isEmpty else {
            resultTextView.text = "Not enough readable content to generate a quiz."
            return
        }

        var quiz = "Generated Quiz\n\n"
        quiz += "Multiple Choice Questions:\n\n"

        let options = [
            "A key idea discussed in the uploaded file",
            "A topic unrelated to the uploaded file",
            "A random technical error",
            "A file formatting setting"
        ]

        for (index, keyword) in keywords.enumerated() {
            quiz += """
            \(index + 1). What is "\(keyword)" most likely related to in the uploaded file?
            A. \(options[0])
            B. \(options[1])
            C. \(options[2])
            D. \(options[3])

            """
        }

        quiz += "True / False Questions:\n\n"

        let tfKeywords = Array(keywords.prefix(3))

        for (index, keyword) in tfKeywords.enumerated() {
            quiz += """
            \(index + 6). "\(keyword)" appears to be an important concept in the uploaded file.
            True / False

            """
        }

        resultTextView.text = quiz
    }
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let fileURL = urls.first else { return }

        selectedFileURL = fileURL
        uploadFileButton.setTitle(fileURL.lastPathComponent, for: .normal)
        resultTextView.text = "File uploaded. Choose Summarize, Explain, or Quiz."

        loadTextFromFile(fileURL)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker cancelled")
    }

    private func loadTextFromFile(_ fileURL: URL) {
        selectedFileText = ""

        let canAccess = fileURL.startAccessingSecurityScopedResource()

        defer {
            if canAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        let fileExtension = fileURL.pathExtension.lowercased()

        if fileExtension == "txt" {
            loadTXT(from: fileURL)
        } else if fileExtension == "pdf" {
            loadPDF(from: fileURL)
        } else if fileExtension == "doc" || fileExtension == "docx" {
            loadWordFile(from: fileURL)
        } else {
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

        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex),
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
            resultTextView.text = "Could not directly read DOC/DOCX. Backend support will be needed later."
        }
    }
}
