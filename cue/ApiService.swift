//
//  ApiService.swift
//  cue
//
//  Created by Michael Yang on 3/20/25.
//
import Foundation

// API Response Model
struct APIResponse: Decodable {
    let generatedText: String
}

// API Service
class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:11434"
    var accumulatedData: Data = Data()
    
    func generateText(prompt: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            print("Bad url")
            throw URLError(.badURL)
        }

        let model = "gemma3:4b"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
        let (bytes, response) = try await URLSession.shared.bytes(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        var responseString = ""
        for try await line in bytes.lines {
            if let jsonData = line.data(using: .utf8) {
                do {
                    // Deserialize into a dictionary and build response string
                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        if let model = jsonObject["model"] as? String,
                           let response = jsonObject["response"] as? String, let done = jsonObject["done"] as? Bool {
                            print(response)
                            responseString.append(response)
                        }
                    }
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }
        }
        return responseString
    }
    
    
}

