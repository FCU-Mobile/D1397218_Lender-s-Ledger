//
//  QRCodeGenerator.swift
//  Lender-s-Ledger
//
//  Created by QR Code Sharing Feature
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeShareView: View {
    let item: LedgerItem
    @Environment(\.dismiss) var dismiss
    @State private var qrCodeImage: UIImage?
    @State private var errorMessage: String?
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Share Item via QR Code")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("Ask someone to scan this QR code to add \"\(item.name)\" to their ledger")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if isGenerating {
                    ProgressView("Generating QR Code...")
                        .frame(width: 200, height: 200)
                } else if let qrImage = qrCodeImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else if let error = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error generating QR code")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 200, height: 200)
                }
                
                if qrCodeImage != nil {
                    ShareLink(item: qrCodeImage!, preview: SharePreview("QR Code for \(item.name)")) {
                        Label("Share QR Code", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Share Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            generateQRCode()
        }
    }
    
    private func generateQRCode() {
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                // Create shareable data from item
                let shareableData = ShareableLedgerItem.from(item)
                let jsonData = try JSONEncoder().encode(shareableData)
                let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
                
                // Generate QR code
                let qrImage = await QRCodeGenerator.generateQRCode(from: jsonString)
                
                await MainActor.run {
                    self.qrCodeImage = qrImage
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isGenerating = false
                }
            }
        }
    }
}

// Simplified data structure for sharing (excludes private data like IDs and images)
struct ShareableLedgerItem: Codable {
    let name: String
    let person: String
    let type: String
    let date: Date
    let returnByDate: Date?
    let conditionNotes: String?
    let tags: [String]
    
    static func from(_ item: LedgerItem) -> ShareableLedgerItem {
        return ShareableLedgerItem(
            name: item.name,
            person: item.person,
            type: item.type.rawValue,
            date: item.date,
            returnByDate: item.returnByDate,
            conditionNotes: item.conditionNotes,
            tags: item.tags
        )
    }
    
    func toLedgerItem() -> LedgerItem {
        return LedgerItem(
            name: name,
            person: person,
            type: ItemType(rawValue: type) ?? .lent,
            date: date,
            returnByDate: returnByDate,
            conditionNotes: conditionNotes,
            tags: tags
        )
    }
}

class QRCodeGenerator {
    static func generateQRCode(from string: String) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let context = CIContext()
            let filter = CIFilter.qrCodeGenerator()
            
            guard let data = string.data(using: .utf8) else {
                continuation.resume(returning: nil)
                return
            }
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            guard let ciImage = filter.outputImage else {
                continuation.resume(returning: nil)
                return
            }
            
            // Scale the image up for better quality
            let scaleX = 200
            let scaleY = 200
            let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: CGFloat(scaleX), y: CGFloat(scaleY)))
            
            guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
                continuation.resume(returning: nil)
                return
            }
            
            let uiImage = UIImage(cgImage: cgImage)
            continuation.resume(returning: uiImage)
        }
    }
}

#Preview {
    QRCodeShareView(item: LedgerItem(
        name: "Sample Book", 
        person: "John Doe", 
        type: .lent, 
        date: Date()
    ))
}