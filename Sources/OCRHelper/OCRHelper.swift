//  OCRHelper.swift
//
//  Copyright (c) 2023 Jonathan Chacón
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftUI
import Foundation
import Vision
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public final class OCRHelper {
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
