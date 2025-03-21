//
//  Lllama.swift
//  cue
//
//  Created by Michael Yang on 3/20/25.
//
import Foundation
//NO LONGER NEEDED
class OllamaService {
    static let shared = OllamaService()
    
    func runOllamaCommand(prompt: String) async throws -> String {
        let task = Process()
        let ollamaPath = "/usr/local/bin/ollama"
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", "echo \(prompt) | \(ollamaPath) run gemma3:4b"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            }
            return "No response from Ollama"
        } catch {
            print("Error running Ollama: \(error.localizedDescription)")
            throw error
        }
    }
}


