//
//  ImageProcessor.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 13.06.2022.
//

import Foundation

class ImageProcessor: Operation {
    
    var imageOutput: ((NSImage) -> Void)?
    private var inputDataURL: URL
    private(set) var blurValue: Int
    private let gaussBlurer: GaussianWrapper
    
    init(for inputDataURL: URL, by blurValue: Int = 0) {
        self.inputDataURL = inputDataURL
        self.blurValue = blurValue
        self.gaussBlurer = GaussianWrapper()
        self.gaussBlurer.setPath(inputDataURL.path)
        self.gaussBlurer.setBlurLevel(0)
        super.init()
    }
    
    override func main() {
        self.gaussBlurer.setBlurLevel(self.blurValue)
        guard let blurredImage = self.gaussBlurer.blurredOutput() else { return }
        
        if let imageOutput = self.imageOutput {
            DispatchQueue.main.async {
                imageOutput(blurredImage)
            }
        }
    }
}
