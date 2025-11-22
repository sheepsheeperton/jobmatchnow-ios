import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onFilePicked: (URL) -> Void
    let onError: (Error) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        print("DEBUG: Creating UIDocumentPickerViewController")

        // Configure allowed document types
        let documentTypes: [UTType] = [
            .pdf,
            .plainText,
            .rtf,
            UTType(filenameExtension: "docx") ?? .data,
            UTType(filenameExtension: "doc") ?? .data,
            UTType(filenameExtension: "txt") ?? .data
        ]

        print("DEBUG: Allowed document types:", documentTypes.map { $0.identifier })

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes, asCopy: false)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true

        print("DEBUG: UIDocumentPickerViewController configured")
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
            print("DEBUG: DocumentPicker.Coordinator initialized")
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("DEBUG: documentPicker didPickDocumentsAt called with \(urls.count) URLs")

            guard let url = urls.first else {
                print("DEBUG: No URL in picked documents")
                parent.isPresented = false
                return
            }

            print("DEBUG: Picked document URL:", url)
            print("DEBUG: File name:", url.lastPathComponent)
            print("DEBUG: Path:", url.path)
            print("DEBUG: Is file URL:", url.isFileURL)
            print("DEBUG: Has security scope:", url.startAccessingSecurityScopedResource())

            // Detect MIME type
            if let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]),
               let contentType = resourceValues.contentType {
                print("DEBUG: Content type identifier:", contentType.identifier)
                print("DEBUG: Preferred MIME type:", contentType.preferredMIMEType ?? "none")
            }

            // Dismiss picker
            print("DEBUG: Dismissing picker and calling onFilePicked")
            parent.isPresented = false

            // Call the completion handler with the picked URL
            parent.onFilePicked(url)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("DEBUG: Document picker was cancelled by user")
            parent.isPresented = false
        }
    }
}
