//
//  ViewController.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 11.06.2022.
//

import Cocoa
import RxSwift

class ViewController: NSViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var openButton: NSButton!
    @IBOutlet private weak var saveButton: NSButton!
    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet private weak var blurLevelSlider: NSSlider!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var blurLevelLabel: NSTextField!
    
    //MARK: - Other properties
    private var imageURL: URL?
    private var gauss: GaussianWrapper?
    private let blurringOperations = OperationQueue()
    private var prevOperation: ImageProcessor?
    
    private var bag = DisposeBag()
    private var sliderValue = PublishSubject<Int>()
    
    //MARK: - Setup values
    private let backgroundBlurLevel = 25
    
    //MARK: - Delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.gauss = GaussianWrapper()
        self.imageView.wantsLayer = true
        self.setupUI()
        self.bindUI()
    }
    
    //MARK: - IBActions
    @IBAction func openImage(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { [weak self] result in
            if result == .OK, let url = openPanel.url {
                self?.enableSpinner(true)
                self?.imageURL = url
                self?.blurLevelSlider.doubleValue = 0.0
                self?.prepareBackgroundView()
                self?.prepareImageView()
                self?.enableSpinner(false)
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
            guard let tiffRep = (self.imageView.layer?.contents as? NSImage)?.tiffRepresentation,
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
        sliderValue.onNext(sender.integerValue)
    }
    
    //MARK: - Setup
    private func setupUI() {
        self.blurLevelSlider.minValue = 0.0
        self.blurLevelSlider.maxValue = 50
        self.blurLevelSlider.integerValue = 0
        self.blurLevelSlider.isContinuous = true
        self.saveButton.isEnabled = false
        self.blurLevelSlider.isHidden = true
        self.enableSpinner(false)
    }
    
    private func bindUI() {
        sliderValue
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.applyBlurForImage(by: value)
            })
            .disposed(by: bag)
        
        sliderValue
            .subscribe { [weak self] value in
                self?.blurLevelLabel.isHidden = false
                self?.enableSpinner(true)
                self?.blurLevelLabel.stringValue =
                "\(Int(Double(value.element ?? 0) / 50 * 100))%"
            }
            .disposed(by: bag)
    }
    
    private func prepareImageView() {
        guard let url = self.imageURL else { return }
        self.blurLevelSlider.isHidden = false
        let operation = ImageProcessor(for: url)
        operation.onImageProcced = { [weak self] image in
            guard let view = self?.imageView else { return }
            self?.setViewContent(for: view, with: image)
        }
        self.blurringOperations.addOperation(operation)
    }
    
    private func prepareBackgroundView() {
        guard let url = imageURL else { return }
        let operation = ImageProcessor(for: url, by: self.backgroundBlurLevel)
        operation.onImageProcced = { [weak self] image in
            guard let view = self?.view else { return }
            self?.setViewContent(for: view, with: image)
        }
        self.blurringOperations.addOperation(operation)
    }
    
    //MARK: - Supporting methods
    private func enableSpinner(_ status: Bool) {
        self.progressIndicator.isHidden = !status
        status ? self.progressIndicator.startAnimation(nil) : self.progressIndicator.stopAnimation(nil)
    }
    
    private func applyBlurForImage(by value: Int) {
        guard let url = self.imageURL else { return }
        
        let blurOperation = ImageProcessor(for: url, by: value)
        blurOperation.onImageProcced = { [weak self] image in
            guard let view = self?.imageView else { return }
            self!.setViewContent(for: view, with: image)
        }

        if let prevOperation = self.prevOperation, !prevOperation.isCancelled {
            self.prevOperation = blurOperation
            if blurOperation.blurValue == prevOperation.blurValue {
                return
            }
        }
        
        self.blurringOperations.cancelAllOperations()
        
        self.blurringOperations.addOperation(blurOperation)
        
        self.enableSpinner(false)
        self.saveButton.isEnabled = true
    }
    
    private func setViewContent(for view: NSView, with image: NSImage) {
        let layer = CALayer()
        layer.contentsGravity = view is NSImageView ? .resizeAspect : .resizeAspectFill
        layer.contents = image
        view.layer = layer
    }
    
}
