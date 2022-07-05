//
//  MenuController.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 05.07.2022.
//

import Cocoa

enum FilterButtonType: String  {
    case blur = "Blur"
    case sepia = "Sepia"
    case duoTone = "Duo tone"
    case pencil = "Pencil"
    case cartoon = "Cartoon"
}

protocol FilterMenuDelegate: AnyObject {
    func tappedFilterButton(filter: FilterButtonType)
}

class MenuController: NSViewController {
    
    var pressedButtonType: FilterButtonType = .blur
    
    weak var delegate: FilterMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBAction private func applyFilter(_ sender: NSButton) {
        let buttonName = FilterButtonType(rawValue: sender.title)
        
        switch buttonName {
        case .blur:
            self.delegate?.tappedFilterButton(filter: .blur)
        case .sepia:
            self.delegate?.tappedFilterButton(filter: .sepia)
        case .duoTone:
            self.delegate?.tappedFilterButton(filter: .duoTone)
        case .pencil:
            self.delegate?.tappedFilterButton(filter: .pencil)
        case .cartoon:
            self.delegate?.tappedFilterButton(filter: .cartoon)
        case .none:
            break
        }
    }
    
}
