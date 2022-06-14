//
//  ViewController.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 11.06.2022.
//

import Cocoa
import CoreImage.CIFilterBuiltins

class ViewController: NSViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var openButton: NSButton!
    @IBOutlet private weak var saveButton: NSButton!
    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet private weak var blurLevelSlider: NSSlider!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    
    //MARK: - Other properties
    private var imageURL: URL?
    private var gauss: GaussianWrapper?
    private let blurringOperations = OperationQueue()
    private var activeOperations = [Int:Operation]()
    
    //MARK: - Setup values
    private let backgroundBlurLevel = 25
    
    //MARK: - Delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gauss = GaussianWrapper()
        self.view.wantsLayer = true
        self.imageView.wantsLayer = true
        setupUI()
    }
    
    //MARK: - IBActions
    @IBAction func openImage(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { [weak self] result in
            if result == .OK, let url = openPanel.url {
                self?.imageURL = url
                self?.prepareBackgroundView()
                self?.prepareImageView()
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
    
    @IBAction func changePhotoBlur(_ sender: NSSlider) {
        guard let url = self.imageURL else { return }
        let operation = ImageProcessor(for: url, by: self.blurLevelSlider.integerValue)
        operation.imageOutput = { [weak self] image in
            self!.setViewContent(for: self!.imageView, with: image)
        }
        self.blurringOperations.addOperation(operation)
    }
    
    //MARK: - Setup
    private func setupUI() {
        self.blurLevelSlider.minValue = 0.0
        self.blurLevelSlider.maxValue = 50
        self.blurLevelSlider.isContinuous = true
        self.saveButton.isEnabled = false
        self.blurLevelSlider.isHidden = true
        self.enableSpinner(false)
    }
    
    private func prepareImageView() {
        guard let url = self.imageURL else { return }
        self.blurLevelSlider.isHidden = false
        let operation = ImageProcessor(for: url)
        operation.imageOutput = { image in
            self.setViewContent(for: self.imageView, with: image)
        }
        self.blurringOperations.addOperation(operation)
    }
    
    private func prepareBackgroundView() {
        guard let url = imageURL else { return }
        let operation = ImageProcessor(for: url, by: self.backgroundBlurLevel)
        operation.imageOutput = { image in
            self.setViewContent(for: self.view, with: image)
        }
        self.blurringOperations.addOperation(operation)
    }
    
    //MARK: - Supporting methods
    private func enableSpinner(_ status: Bool) {
        self.progressIndicator.isHidden = !status
        status ? self.progressIndicator.startAnimation(nil) : self.progressIndicator.stopAnimation(nil)
    }
    
    private func setViewContent(for view: NSView, with image: NSImage) {
        let layer = CALayer()
        layer.contentsGravity = view is NSImageView ? .resizeAspect : .resizeAspectFill
        layer.contents = image
        view.layer = layer
    }
    
}
