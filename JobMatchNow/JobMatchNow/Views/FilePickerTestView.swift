import SwiftUI
import UniformTypeIdentifiers

struct FilePickerTestView: View {
    @State private var isImporterPresented = false
    @State private var selectedFileName: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("File Picker Debug")
                .font(.title)

            Button("Choose File") {
                isImporterPresented = true
            }
            .buttonStyle(.borderedProminent)

            if let name = selectedFileName {
                Text("Selected: \(name)")
                    .foregroundColor(.green)
            } else {
                Text("No file selected")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.item],   // most permissive for debugging
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                selectedFileName = url.lastPathComponent
                print("DEBUG Picked file URL:", url)
            case .failure(let error):
                print("DEBUG File import error:", error)
            }
        }
    }
}

#Preview {
    FilePickerTestView()
}
