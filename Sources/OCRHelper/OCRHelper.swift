import SwiftUI
import Foundation
import Vision
#if os(macOS)
import AppKit
#else
import UIKit
#endif

final class OCRHelper {
    public static var supportedLanguages: [String] {
        do {
            return try VNRecognizeTextRequest().supportedRecognitionLanguages()
        } catch {
            print("TextRecognitionHelper-supportedLanguages: \(error.localizedDescription)")
            return []
        }
    }
    
    public static func recognize(cgImage: CGImage,
                                 languages: [String]? = nil,
                                 level: VNRequestTextRecognitionLevel = .accurate,
                                 completed: @escaping ([String]?, Error?) -> Void) {
        let listLanguages: [String]
        if languages != nil {
            listLanguages = languages!
        } else {
            listLanguages = OCRHelper.supportedLanguages
        }
        var results = [String]()
        let request = VNRecognizeTextRequest { (request, error) in
            for observation in request.results as! [VNRecognizedTextObservation] {
                for candidate in observation.topCandidates(1) {
                    results.append(candidate.string)
                }
            }
            completed(results, nil)
        }
        request.recognitionLanguages = listLanguages
        request.recognitionLevel = level
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try imageRequestHandler.perform([request])
        } catch {
            completed(nil, error)
        }
    }
#if os(macOS)
    
    public static func recognize(image: NSImage,
                                 languages: [String]? = nil,
                                 level: VNRequestTextRecognitionLevel = .accurate,
                                 completed: @escaping ([String]?, Error?) -> Void) {
        let listLanguages: [String]
        if languages != nil {
            listLanguages = languages!
        } else {
            listLanguages = OCRHelper.supportedLanguages
        }
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completed(nil, NSError(domain: "TextRecognizer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert NSImage to CGImage"]))
            return
        }
        recognize(cgImage: cgImage,
                  languages: listLanguages,
                  level: level,
                  completed: completed)
    }
    
#else
    
    public static func recognize(image: UIImage,
                                 languages: [String]? = nil,
                                 level: VNRequestTextRecognitionLevel = .accurate,
                                 completed: @escaping ([String]?, Error?) -> Void) {
        let listLanguages: [String]
        if languages != nil {
            listLanguages = languages!
        } else {
            listLanguages = OCRHelper.supportedLanguages
        }
        guard let cgImage = image.cgImage else {
            completed(nil, NSError(domain: "TextRecognizer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert NSImage to CGImage"]))
            return
        }
        recognize(cgImage: cgImage,
                  languages: listLanguages,
                  level: level,
                  completed: completed)
    }
    
#endif
}
