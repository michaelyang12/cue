import SwiftUI
import Cocoa
import Foundation
import AppKit


struct GeneratedItem: Identifiable {
    let id: UUID
    let prompt: String
    let generatedText: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var generatedItems: [GeneratedItem] = []
    @State private var isGenerating = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("Cue")
                .font(.title3)
                .bold()
            
            TextField("Enter your prompt...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: generateText) {
                Text(isGenerating ? "Generating..." : "Generate")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.isEmpty || isGenerating)
            .padding(.horizontal)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            if !generatedItems.isEmpty {
                List {
                    ForEach(generatedItems) { item in
                        GeneratedItemView(item: item, onDelete: removeItem)
                    }
                }
                .frame(minHeight: 300, maxHeight: 600)
            }
        }
        .padding()
        .frame(width: 300)
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
                        let newItem = GeneratedItem(id: UUID(), prompt: prompt, generatedText: generatedText)
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

    private func removeItem(_ id: UUID) {
        generatedItems.removeAll { $0.id == id }
    }
}

struct GeneratedItemView: View {
    let item: GeneratedItem
    let onDelete: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.prompt)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
                .padding(8)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
//            if let attributedString = try? AttributedString(item.generatedText) {
            Text(try! AttributedString(markdown: item.generatedText, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
//            } else {
//                Text(item.generatedText)
//                    .padding(8)
//                    .background(Color.gray.opacity(0.2))
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//            }
            
            HStack {
                Button("Copy") {
                    let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(item.generatedText, forType: .string)
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Remove") {
                    onDelete(item.id)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 4)
    }
}

//
//// Custom shape for top-rounded rectangle (for headers)
//struct TopRoundedRectangle: Shape {
//    var radius: CGFloat
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        
//        // Top-left corner
//        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
//        
//        // Top edge and top-right corner
//        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
//        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
//                   radius: radius,
//                   startAngle: Angle(degrees: -90),
//                   endAngle: Angle(degrees: 0),
//                   clockwise: false)
//        
//        // Right edge
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//        
//        // Bottom edge (straight)
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
//        
//        // Left edge
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
//        
//        // Top-left corner
//        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
//                   radius: radius,
//                   startAngle: Angle(degrees: 180),
//                   endAngle: Angle(degrees: 270),
//                   clockwise: false)
//        
//        return path
//    }
//}
//
//// Custom shape for bottom-rounded rectangle (for content)
//struct BottomRoundedRectangle: Shape {
//    var radius: CGFloat
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        
//        // Top edge (straight)
//        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//        
//        // Right edge and bottom-right corner
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
//        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
//                   radius: radius,
//                   startAngle: Angle(degrees: 0),
//                   endAngle: Angle(degrees: 90),
//                   clockwise: false)
//        
//        // Bottom edge and bottom-left corner
//        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
//        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
//                   radius: radius,
//                   startAngle: Angle(degrees: 90),
//                   endAngle: Angle(degrees: 180),
//                   clockwise: false)
//        
//        // Left edge
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
//        
//        return path
//    }
//}
