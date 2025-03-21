import SwiftUI
import Cocoa
import Foundation

// Generated Text Item Model
struct GeneratedTextItem: Identifiable {
    let id = UUID()
    let prompt: String
    let generatedText: String
}

// Content View
struct ContentView: View {
    @State private var inputText: String = ""
    @State private var generatedItems: [GeneratedTextItem] = []
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Text Generator")
                .font(.headline)
                .padding(.top, 8)
            
            TextField("Enter your prompt", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Generate") {
                generateText()
            }
            .disabled(inputText.isEmpty || isGenerating)
            
            if isGenerating {
                ProgressView()
                    .padding()
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            if !generatedItems.isEmpty {
                Text("Generated Results:")
                    .font(.subheadline)
                    .padding(.top, 4)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(generatedItems) { item in
                            VStack(alignment: .leading, spacing: 0) {
                                // Header with prompt using standard rounded rectangle
                                Text(item.prompt)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.blue)
                                    .clipShape(TopRoundedRectangle(radius: 8))
                                
                                // Generated text using standard rounded rectangle
                                Text(item.generatedText)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(BottomRoundedRectangle(radius: 8))
                                
                                HStack {
                                    Button("Copy") {
                                        copyToClipboard(text: item.generatedText)
                                    }
                                    .buttonStyle(.borderless)
                                    .controlSize(.small)
                                    
                                    Spacer()
                                    
                                    Button("Remove") {
                                        if let index = generatedItems.firstIndex(where: { $0.id == item.id }) {
                                            generatedItems.remove(at: index)
                                        }
                                    }
                                    .buttonStyle(.borderless)
                                    .controlSize(.small)
                                }
                                .padding(.horizontal, 4)
                                .padding(.bottom, 4)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func generateText() {
        let prompt = inputText
        isGenerating = true
        errorMessage = nil
        
        // Using Task for async/await
        Task {
            do {
                // Use this for real API calls
                let generatedText = try await APIService.shared.generateText(prompt: prompt)
//                let generatedText = try await OllamaService.shared.runOllamaCommand(prompt: prompt)
                
                // Update UI on main thread
                await MainActor.run {
                    // Add new item to the beginning of the list
                    let newItem = GeneratedTextItem(prompt: prompt, generatedText: generatedText)
                    generatedItems.insert(newItem, at: 0)
                    
                    // Reset
                    isGenerating = false
                    inputText = ""
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isGenerating = false
                }
            }
        }
    }
    
    func copyToClipboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

// Custom shape for top-rounded rectangle (for headers)
struct TopRoundedRectangle: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Top-left corner
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        
        // Top edge and top-right corner
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                   radius: radius,
                   startAngle: Angle(degrees: -90),
                   endAngle: Angle(degrees: 0),
                   clockwise: false)
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Bottom edge (straight)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        
        // Top-left corner
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                   radius: radius,
                   startAngle: Angle(degrees: 180),
                   endAngle: Angle(degrees: 270),
                   clockwise: false)
        
        return path
    }
}

// Custom shape for bottom-rounded rectangle (for content)
struct BottomRoundedRectangle: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Top edge (straight)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Right edge and bottom-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                   radius: radius,
                   startAngle: Angle(degrees: 0),
                   endAngle: Angle(degrees: 90),
                   clockwise: false)
        
        // Bottom edge and bottom-left corner
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                   radius: radius,
                   startAngle: Angle(degrees: 90),
                   endAngle: Angle(degrees: 180),
                   clockwise: false)
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        return path
    }
}
