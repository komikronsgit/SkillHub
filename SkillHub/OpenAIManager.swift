//
//  OpenAIManager.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-05-29.
//

import Foundation

class OpenAIManager {

    static let shared = OpenAIManager()

    private init() {}

    // MARK: - API Key
    private let apiKey = Config.openAIKey

    // MARK: - Main AI Function
    func sendMessage(prompt: String,
                     completion: @escaping (Result<String, Error>) -> Void) {

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Headers
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Body
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful AI study assistant for students. Explain clearly and simply."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // API Call
        URLSession.shared.dataTask(with: request) { data, response, error in

            // Handle error
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data returned", code: -1)))
                return
            }

            do {
                // Parse JSON response
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                guard
                    let choices = json?["choices"] as? [[String: Any]],
                    let message = choices.first?["message"] as? [String: Any],
                    let content = message["content"] as? String
                else {
                    completion(.failure(NSError(domain: "Invalid response format", code: -2)))
                    return
                }

                completion(.success(content))

            } catch {
                completion(.failure(error))
            }

        }.resume()
    }

    // MARK: - Helper Prompts (IMPORTANT FOR YOUR FEATURES)

    func summarize(text: String) -> String {
        return """
        Summarize the following content clearly and simply:

        \(text)
        """
    }

    func explainSimply(text: String) -> String {
        return """
        Explain this in very simple terms so a student can understand:

        \(text)
        """
    }

    func generateQuiz(text: String) -> String {
        return """
        Create a quiz based on the following content.
        Include:
        - 5 multiple choice questions
        - 3 true/false questions
        - Provide answers at the end

        Content:
        \(text)
        """
    }

    func chat(text: String) -> String {
        return text
    }

    func fileAndQuestion(fileText: String, question: String) -> String {
        return """
        Use the following file content to answer the question.

        FILE CONTENT:
        \(fileText)

        QUESTION:
        \(question)
        """
    }
}
