import Foundation

enum AppResources {
    /// Returns the URL for the bundled sample resume PDF.
    /// This file should be added to the Xcode target's resources.
    static func sampleResumeURL() -> URL? {
        return Bundle.main.url(forResource: "SampleResume", withExtension: "pdf")
    }
}
