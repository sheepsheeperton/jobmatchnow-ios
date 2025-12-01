//
//  ImageProcessor.swift
//  JobMatchNow
//
//  Utility for preparing scanned images for upload.
//  Handles orientation normalization, compression, and temp file creation.
//

import UIKit

// MARK: - Image Processor

/// Utility enum for processing scanned images before upload.
/// Ensures images are properly oriented, reasonably sized, and saved as JPEG.
enum ImageProcessor {
    
    // MARK: - Configuration
    
    /// Maximum dimension (width or height) for resized images
    private static let maxDimension: CGFloat = 2048
    
    /// JPEG compression quality (0.0 - 1.0)
    private static let compressionQuality: CGFloat = 0.85
    
    // MARK: - Public Methods
    
    /// Prepares a scanned image for upload.
    /// - Parameter image: The UIImage from the document scanner
    /// - Returns: A file URL to the processed JPEG, or nil if processing fails
    ///
    /// This method:
    /// 1. Normalizes the image orientation (fixes EXIF rotation)
    /// 2. Resizes if larger than maxDimension
    /// 3. Compresses to JPEG
    /// 4. Saves to a temporary file
    static func prepareForUpload(_ image: UIImage) -> URL? {
        print("[ImageProcessor] Processing image: \(Int(image.size.width))x\(Int(image.size.height))")
        
        // Step 1: Normalize orientation
        let normalizedImage = normalizeOrientation(image)
        
        // Step 2: Resize if needed
        let resizedImage = resizeIfNeeded(normalizedImage)
        print("[ImageProcessor] After resize: \(Int(resizedImage.size.width))x\(Int(resizedImage.size.height))")
        
        // Step 3: Convert to JPEG data
        guard let jpegData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            print("[ImageProcessor] ❌ Failed to create JPEG data")
            return nil
        }
        
        let fileSizeKB = Double(jpegData.count) / 1024.0
        print("[ImageProcessor] JPEG size: \(String(format: "%.1f", fileSizeKB)) KB")
        
        // Step 4: Save to temp file
        let tempURL = createTempFileURL()
        
        do {
            try jpegData.write(to: tempURL)
            print("[ImageProcessor] ✅ Saved to: \(tempURL.lastPathComponent)")
            return tempURL
        } catch {
            print("[ImageProcessor] ❌ Failed to write file: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    /// Normalizes image orientation by redrawing with correct transform.
    /// Camera images often have EXIF orientation data that isn't applied to the pixel data.
    private static func normalizeOrientation(_ image: UIImage) -> UIImage {
        // If orientation is already correct, return as-is
        guard image.imageOrientation != .up else {
            return image
        }
        
        // Redraw the image with the correct orientation
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? image
    }
    
    /// Resizes the image if either dimension exceeds maxDimension.
    /// Maintains aspect ratio.
    private static func resizeIfNeeded(_ image: UIImage) -> UIImage {
        let size = image.size
        
        // Check if resize is needed
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        // Resize using UIGraphicsImageRenderer for better quality
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    /// Creates a unique temporary file URL for the processed image.
    private static func createTempFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "scanned_resume_\(UUID().uuidString).jpg"
        return tempDir.appendingPathComponent(filename)
    }
    
    // MARK: - Cleanup
    
    /// Removes a temporary file created by prepareForUpload.
    /// Call this after the upload completes or fails.
    static func cleanup(tempFileURL: URL) {
        do {
            try FileManager.default.removeItem(at: tempFileURL)
            print("[ImageProcessor] Cleaned up temp file: \(tempFileURL.lastPathComponent)")
        } catch {
            // Ignore errors - temp files will be cleaned up by the system eventually
            print("[ImageProcessor] Could not clean up temp file: \(error.localizedDescription)")
        }
    }
}

