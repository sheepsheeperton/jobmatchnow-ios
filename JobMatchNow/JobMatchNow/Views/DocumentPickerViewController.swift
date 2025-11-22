import SwiftUI
import UIKit
import UniformTypeIdentifiers

// Simple UIViewControllerRepresentable wrapper for UIDocumentPickerViewController
struct DocumentPickerViewController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onDocumentPicked: (URL) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        print("DEBUG: [DocumentPickerViewController] makeUIViewController called")

        // Create empty view controller to present from
        let viewController = UIViewController()

        // Configure document types
        let types: [UTType] = [
            .pdf,
            .png,
            .jpeg,
            UTType(filenameExtension: "docx") ?? .data,
            UTType(filenameExtension: "doc") ?? .data
        ]

        print("DEBUG: [DocumentPickerViewController] Supported types:", types.map { $0.identifier })

        // Create document picker
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false

        print("DEBUG: [DocumentPickerViewController] Created picker with delegate")

        // Present the picker after a slight delay to ensure view hierarchy is ready
        DispatchQueue.main.async {
            print("DEBUG: [DocumentPickerViewController] Presenting picker")
            viewController.present(picker, animated: true) {
                print("DEBUG: [DocumentPickerViewController] Picker presentation completed")
            }
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        print("DEBUG: [DocumentPickerViewController] updateUIViewController called")
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        print("DEBUG: [DocumentPickerViewController] makeCoordinator called")
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerViewController

        init(_ parent: DocumentPickerViewController) {
            self.parent = parent
            super.init()
            print("DEBUG: [Coordinator] Initialized")
        }

        // Called when user selects a document
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("DEBUG: [Coordinator] documentPicker:didPickDocumentsAt called")
            print("DEBUG: [Coordinator] Number of URLs:", urls.count)

            guard let url = urls.first else {
                print("DEBUG: [Coordinator] No URL selected")
                parent.isPresented = false
                return
            }

            print("DEBUG: [Coordinator] Document picked successfully")
            print("DEBUG: [Coordinator] URL:", url)
            print("DEBUG: [Coordinator] File name:", url.lastPathComponent)
            print("DEBUG: [Coordinator] Path:", url.path)

            // Get MIME type information
            if let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]) {
                if let contentType = resourceValues.contentType {
                    print("DEBUG: [Coordinator] Content type:", contentType.identifier)
                    print("DEBUG: [Coordinator] MIME type:", contentType.preferredMIMEType ?? "unknown")
                }
            }

            // Dismiss picker
            controller.dismiss(animated: true) {
                print("DEBUG: [Coordinator] Picker dismissed")
                self.parent.isPresented = false
                self.parent.onDocumentPicked(url)
            }
        }

        // Called when user cancels
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("DEBUG: [Coordinator] documentPickerWasCancelled called")
            controller.dismiss(animated: true) {
                print("DEBUG: [Coordinator] Picker dismissed (cancelled)")
                self.parent.isPresented = false
            }
        }
    }
}