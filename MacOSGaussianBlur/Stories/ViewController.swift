//
//  ViewController.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 11.06.2022.
//

import Cocoa
import RxSwift
import RxCocoa

class ViewController: NSViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var openButton: NSButton!
    @IBOutlet private weak var saveButton: NSButton!
    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet private weak var blurLevelSlider: NSSlider!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var blurLevelLabel: NSTextField!
    @IBOutlet private weak var showMenuButton: NSButton!
    
    //MARK: - Other properties
    private var filterMenuController = MenuController()
    private var trailingConstraint: NSLayoutConstraint?
    
    private var imageURL: URL?
    private var gauss: GaussianWrapper?
    private let blurringOperations = OperationQueue()
    private var prevOperation: ImageProcessor?
    
    private var bag = DisposeBag()
    
    private var isOpenMenu = false
    
    //MARK: - Setup values
    private let backgroundBlurLevel = 25
    private var currentFilter: FilterButtonType = .blur
    
    //MARK: - Delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.gauss = GaussianWrapper(FilterButtonType.blur.rawValue)
        self.imageView.wantsLayer = true
        self.setupUI()
        self.bindUI()
        self.filterMenuController.delegate = self
        makeConstraints()
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
    }
    
    //MARK: - IBActions
    @IBAction func showMenu(_ sender: NSButton){
        self.isOpenMenu.toggle()
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 1
            self.trailingConstraint?.animator().constant = isOpenMenu ? 0 : self.filterMenuController.view.frame.width
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    ///Opens image for a specified path
    @IBAction func openImage(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { [weak self] result in
            if result == .OK, let url = openPanel.url {
                self?.enableSpinner(true)
                self?.imageURL = url
                self?.blurLevelSlider.doubleValue = 0.0
                self?.blurringOperations.cancelAllOperations()
                self?.prepareBackgroundView()
                self?.prepareImageView()
                self?.enableSpinner(false)
            }
        }
    }
    
    ///Saves an image
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
    
    //MARK: - Setup
    
    ///Prepares UI
    private func setupUI() {
        self.blurLevelSlider.minValue = 0.0
        self.blurLevelSlider.maxValue = 100.0
        self.blurLevelSlider.integerValue = 0
        self.blurLevelSlider.isContinuous = true
        self.saveButton.isEnabled = false
        self.blurLevelSlider.isHidden = true
        self.enableSpinner(false)
    }
    
    /// Binds UI (Reactive manner)
    private func bindUI() {
        let blurSlider = blurLevelSlider.rx.value.changed.share()
        
        blurSlider
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.applyBlurForImage(by: Int(value))
            })
            .disposed(by: bag)
        
        blurSlider
            .subscribe { [weak self] value in
                self?.blurLevelLabel.isHidden = false
                self?.enableSpinner(true)
                self?.blurLevelLabel.stringValue =
                "\(Int(value.element ?? 0))%"
            }
            .disposed(by: bag)
    }
    
    ///Puts image blurring operation to a queue
    private func prepareImageView() {
        guard let url = self.imageURL else { return }
        self.blurLevelSlider.isHidden = self.isSliderEnabled(filter: self.currentFilter)
        let operation = ImageProcessor(for: url, type: self.currentFilter)
        operation.onImageProcced = { [weak self] image in
            guard let view = self?.imageView else { return }
            self?.setViewContent(for: view, with: image)
        }
        self.blurringOperations.addOperation(operation)
    }
    
    ///Puts background blurring operation to a queue
    private func prepareBackgroundView() {
        guard let url = imageURL else { return }
        let operation = ImageProcessor(for: url, by: self.backgroundBlurLevel, type: .blur)
        operation.onImageProcced = { [weak self] image in
            guard let view = self?.view else { return }
            self?.setViewContent(for: view, with: image)
        }
        self.blurringOperations.addOperation(operation)
    }
    
    //MARK: - Supporting methods
    
    ///Hides and shows a spinner
    private func enableSpinner(_ status: Bool) {
        self.progressIndicator.isHidden = !status
        status ? self.progressIndicator.startAnimation(nil) : self.progressIndicator.stopAnimation(nil)
    }
    
    private func isSliderEnabled(filter: FilterButtonType) -> Bool {
        switch filter {
        case .blur, .pencil, .duoTone:
            return false
        case .sepia, .cartoon:
            return true
        }
    }
    
    ///Applies blur for an image
    private func applyBlurForImage(by value: Int) {
        guard let url = self.imageURL else { return }
        
        let blurOperation = ImageProcessor(for: url, by: value, type: self.currentFilter)
        blurOperation.onImageProcced = { [weak self] image in
            guard let view = self?.imageView else { return }
            self!.setViewContent(for: view, with: image)
        }
        
        blurOperation.completionBlock = {[weak self] in
            DispatchQueue.main.async {
                self?.enableSpinner(false)
                self?.blurLevelLabel.isHidden = true
                self?.saveButton.isEnabled = true
            }
        }
        
        if let prevOperation = self.prevOperation, !prevOperation.isCancelled {
            self.prevOperation = blurOperation
            if blurOperation.blurValue == prevOperation.blurValue {
                return
            }
        }
        
        self.blurringOperations.cancelAllOperations()
        self.blurringOperations.addOperation(blurOperation)
    }
    
    ///Sets an image for exact view
    private func setViewContent(for view: NSView, with image: NSImage) {
        let layer = CALayer()
        layer.contentsGravity = view is NSImageView ? .resizeAspect : .resizeAspectFill
        layer.contents = image
        view.layer = layer
    }
    
}

extension  ViewController {
    
    private func makeConstraints() {
        view.addSubview(filterMenuController.view)
        
        self.trailingConstraint = filterMenuController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: self.filterMenuController.view.frame.width)
        if let constraint = self.trailingConstraint {
            NSLayoutConstraint.activate([ constraint,
                                          filterMenuController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
        }
        
        self.addChild(filterMenuController)
    }
}



extension ViewController: FilterMenuDelegate {
    func tappedFilterButton(filter: FilterButtonType) {
        self.currentFilter = filter
        self.enableSpinner(true)
        self.gauss = GaussianWrapper(filter.rawValue)
        self.blurLevelSlider.doubleValue = 0.0
        self.blurLevelSlider.isHidden = self.isSliderEnabled(filter: filter)
        self.blurringOperations.cancelAllOperations()
        self.prepareBackgroundView()
        self.prepareImageView()
        self.enableSpinner(false)
    }
}
