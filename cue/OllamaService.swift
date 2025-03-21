//
//  Lllama.swift
//  cue
//
//  Created by Michael Yang on 3/20/25.
//
import Foundation

class OllamaService {
    static let shared = OllamaService()
    
    func runOllamaCommand(prompt: String) async throws -> String {
        let task = Process()
        let ollamaPath = "/usr/local/bin/ollama"
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        /*task.executableURL = URL(fileURLWithPath: "/usr/local/bin/ollama") */ // Adjust the path to your ollama installation
        //echo "What is water made of?" | ollama run <model>

        task.arguments = ["-c", "echo \(prompt) | \(ollamaPath) run gemma3:4b"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("Ollama output: \(output)")
                return output
            }
            return "No response from Ollama"
        } catch {
            print("Error running Ollama: \(error.localizedDescription)")
            throw error
        }
    }
}


