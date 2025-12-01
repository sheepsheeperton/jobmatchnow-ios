//
//  DocumentScannerView.swift
//  JobMatchNow
//
//  Wraps Apple's VNDocumentCameraViewController for SwiftUI.
//  Provides document scanning with automatic edge detection and perspective correction.
//

import SwiftUI
import VisionKit

// MARK: - Document Scanner View

/// A SwiftUI wrapper for VNDocumentCameraViewController (Apple's document scanner).
/// Provides automatic edge detection, perspective correction, and high-contrast output
/// optimized for OCR processing.
struct DocumentScannerView: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    /// Called when the user successfully scans a document
    let onScan: (UIImage) -> Void
    
    /// Called when the user cancels the scanner
    let onCancel: () -> Void
    
    // MARK: - Static Properties
    
    /// Returns true if document scanning is supported on this device.
    /// Will be false on simulator or devices without camera.
    static var isSupported: Bool {
        VNDocumentCameraViewController.isSupported
    }
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, onCancel: onCancel)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onScan: (UIImage) -> Void
        let onCancel: () -> Void
        
        init(onScan: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onScan = onScan
            self.onCancel = onCancel
        }
        
        // MARK: - VNDocumentCameraViewControllerDelegate
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("[DocumentScanner] Scan completed with \(scan.pageCount) page(s)")
            
            // For now, we only use the first page
            // Multi-page support could be added in the future
            guard scan.pageCount > 0 else {
                print("[DocumentScanner] No pages scanned")
                onCancel()
                return
            }
            
            let firstPage = scan.imageOfPage(at: 0)
            
            if scan.pageCount > 1 {
                print("[DocumentScanner] ⚠️ Only using first page of \(scan.pageCount) scanned pages")
            }
            
            onScan(firstPage)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            print("[DocumentScanner] User cancelled")
            onCancel()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("[DocumentScanner] ❌ Error: \(error.localizedDescription)")
            onCancel()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DocumentScannerView_Previews: PreviewProvider {
    static var previews: some View {
        if DocumentScannerView.isSupported {
            DocumentScannerView(
                onScan: { image in
                    print("Scanned image: \(image.size)")
                },
                onCancel: {
                    print("Cancelled")
                }
            )
        } else {
            Text("Document scanning not supported on this device")
                .foregroundColor(.secondary)
        }
    }
}
#endif

