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
    
    // If your API returns data in a different format, adjust this
    enum CodingKeys: String, CodingKey {
        case generatedText = "generated_text" // Adjust based on actual API response
    }
}

// API Service
class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:11434"
    var accumulatedData: Data = Data()
    
    func generateText(prompt: String) async throws -> String {
        // Build request URL
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            print("Bad url")
            throw URLError(.badURL)
        }

        // Model name (match it to the curl example)
        let model = "gemma3:4b"

        // Create request object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the request body as a dictionary
        let requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt
        ]
        
        // Convert the request body into JSON data
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Perform the request and get the response
        var responseString = ""
        
//        let (data, response) = try await URLSession.shared.data(for: request)
        let (bytes, response) = try await URLSession.shared.bytes(for: request)

        for try await line in bytes.lines {
            if let jsonData = line.data(using: .utf8) {
                do {
                    // Deserialize into a dictionary
                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        // Now you can access the dictionary
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

        // Check if the response is successful
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
//        if let responseText = String(data: data, encoding: .utf8) {
//            return responseText
//        } else {
//            throw URLError(.cannotParseResponse)
//        }
    
    }
    
    
}

