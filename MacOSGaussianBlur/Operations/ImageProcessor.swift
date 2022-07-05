//
//  ImageProcessor.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 13.06.2022.
//

import Cocoa
import Foundation
import RxSwift

class ImageProcessor: Operation {
    
    ///Operation's main task
    var onImageProcced: ((NSImage) -> Void)?
    private var inputDataURL: URL
    private(set) var blurValue: Int
    ///Our core API
    private let gaussBlurer: GaussianWrapper
    
    init(for inputDataURL: URL, by blurValue: Int = 0, type: FilterButtonType = .blur) {
        self.inputDataURL = inputDataURL
        self.blurValue = blurValue
        self.gaussBlurer = GaussianWrapper(type.rawValue)
        self.gaussBlurer.setPath(inputDataURL.path)
        self.gaussBlurer.setBlurLevel(0)
        super.init()
    }
    
    ///Entry point for operation when it is putted in the OperationQueue
    override func main() {
        //TODO: - Adjust blur strength 
        self.gaussBlurer.setBlurLevel(self.blurValue)
        guard let blurredImage = self.gaussBlurer.blurredOutput() else { return }
        
        guard !isCancelled else { return }
        
        if let imageOutput = self.onImageProcced {
            DispatchQueue.main.async {
                imageOutput(blurredImage)
            }
        }
    }
}
