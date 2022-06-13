//
//  ViewController.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 11.06.2022.
//

import Cocoa
import CoreImage.CIFilterBuiltins

class ViewController: NSViewController {
    
    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var blurLevelSlider: NSSlider!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    @IBAction func openImage(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { [weak self] result in
            if result == .OK, let url = openPanel.url {
                self?.imageURL = url
                self?.applyBlurForBackgroundImage(with: url)
                self?.setImageView(for: url)
                self?.saveButton.isEnabled = true
                self?.blurLevelSlider.isHidden = false
                //self?.enableSpinner(true)
            }
        }
    }
    
    @IBAction func saveImage(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.showsResizeIndicator = true
        savePanel.showsHiddenFiles = false
        savePanel.allowedFileTypes = ["png", "jpeg"]
        savePanel.title = "Choose destination"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            guard let tiffRep = self.imageView.image?.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffRep) else { return }
            let pngData = bitmapImage.representation(using: .png, properties: [:])
            do {
                try pngData?.write(to: url, options: [.atomic])
            } catch {
                print("** file export error **")
            }
        }
    }
    
    private func enableSpinner(_ status: Bool) {
        self.progressIndicator.isHidden = !status
        status ? self.progressIndicator.startAnimation(nil) : self.progressIndicator.stopAnimation(nil)
    }
    
    @IBAction func changePhotoBlur(_ sender: NSSlider) {
        if let url = self.imageURL, let newImage = applyBlurForImage(url, blurLevel: abs(sender.floatValue - 1)) {
            let layer = CALayer()
            layer.contentsGravity = .resizeAspect
            layer.contents = newImage
            imageView.wantsLayer = true
            imageView.layer = layer
        }
    }
    
    private func setImageView(for url: URL) {
        self.imageView.image = NSImage(contentsOf: url)
    }
    
    private func applyBlurForBackgroundImage(with url: URL) {
        guard let url = self.imageURL, let blurredImage = applyBlurForImage(url, blurLevel: 40) else { return }
        
        let layerForView = CALayer();
        layerForView.contentsGravity = .resizeAspectFill;
        layerForView.contents = blurredImage;
        self.view.layer = layerForView
        self.view.wantsLayer = true;
    }
    
    private func applyBlurForImage(_ imageURL: URL, blurLevel: Float) -> NSImage? {
        let input = CIImage(contentsOf: imageURL)!
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = input
        blurFilter.radius = blurLevel
        let output = blurFilter.outputImage!.cropped(to: input.extent)
        
        let rep = NSCIImageRep(ciImage: output)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        return nsImage
        
    }
    
    private func setupUI() {
        self.blurLevelSlider.minValue = 0.0
        self.blurLevelSlider.maxValue = 50
        self.saveButton.isEnabled = false
        self.blurLevelSlider.isHidden = true
        self.enableSpinner(false)
    }
    
}

