//
//  QRCodeScanner.swift
//  Lender-s-Ledger
//
//  Created by QR Code Sharing Feature
//

import SwiftUI
import AVFoundation
import AudioToolbox

struct QRCodeScannerView: View {
    @ObservedObject var viewModel: LedgerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isScanning = true
    @State private var errorMessage: String?
    @State private var scannedItem: LedgerItem?
    @State private var showingItemPreview = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if isScanning {
                    CameraView(onCodeScanned: handleScannedCode)
                        .ignoresSafeArea()
                    
                    // Scanning overlay
                    VStack {
                        Text("Scan QR Code")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        
                        Spacer()
                        
                        // Scanning frame
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 250, height: 250)
                        
                        Spacer()
                        
                        Text("Point your camera at a QR code to scan")
                            .font(.subheadline)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                    .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text("Scanning Error")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(error)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            errorMessage = nil
                            isScanning = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    .padding()
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingItemPreview) {
            if let item = scannedItem {
                ScannedItemPreviewView(
                    item: item,
                    onAdd: {
                        viewModel.addItem(
                            name: item.name,
                            person: item.person,
                            type: item.type,
                            returnByDate: item.returnByDate,
                            conditionNotes: item.conditionNotes,
                            tags: item.tags
                        )
                        dismiss()
                    },
                    onCancel: {
                        scannedItem = nil
                        isScanning = true
                    }
                )
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        isScanning = false
        
        do {
            guard let data = code.data(using: .utf8) else {
                throw QRScanError.invalidData
            }
            
            let shareableItem = try JSONDecoder().decode(ShareableLedgerItem.self, from: data)
            let ledgerItem = shareableItem.toLedgerItem()
            
            scannedItem = ledgerItem
            showingItemPreview = true
            
        } catch {
            errorMessage = "Invalid QR code format. Please scan a valid Lender's Ledger QR code."
        }
    }
}

struct ScannedItemPreviewView: View {
    let item: LedgerItem
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scanned Item")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Review the details before adding to your ledger")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Item details card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(item.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(item.type.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(item.type == .lent ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                                .foregroundColor(item.type == .lent ? .blue : .green)
                                .cornerRadius(8)
                        }
                        
                        Label {
                            Text(item.type == .lent ? "From: \(item.person)" : "To: \(item.person)")
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "person")
                                .foregroundColor(.blue)
                        }
                        
                        Label {
                            Text(item.formattedDate)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                        
                        if let returnDate = item.formattedReturnDate {
                            Label {
                                Text("Return by: \(returnDate)")
                                    .foregroundColor(.secondary)
                            } icon: {
                                Image(systemName: "clock")
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if let notes = item.conditionNotes, !notes.isEmpty {
                            Label {
                                Text(notes)
                                    .foregroundColor(.secondary)
                            } icon: {
                                Image(systemName: "note.text")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if !item.tags.isEmpty {
                            Label {
                                Text("Tags")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            } icon: {
                                Image(systemName: "tag")
                                    .foregroundColor(.blue)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 80))
                            ], spacing: 8) {
                                ForEach(item.tags, id: \.self) { tag in
                                    Text(tag)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: onAdd) {
                            Label("Add to My Ledger", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Cancel", action: onCancel)
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Review Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController(onCodeScanned: onCodeScanned)
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No updates needed
    }
}

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private let onCodeScanned: (String) -> Void
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(onCodeScanned: @escaping (String) -> Void) {
        self.onCodeScanned = onCodeScanned
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onCodeScanned(stringValue)
        }
    }
}

enum QRScanError: Error {
    case invalidData
    case decodingFailed
}

#Preview {
    QRCodeScannerView(viewModel: LedgerViewModel())
}