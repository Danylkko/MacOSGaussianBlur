//
//  MyNSTextFieldCell.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 30.06.2022.
//

import Cocoa

class MyNSTextFieldCell: NSTextFieldCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        self.drawsBackground = true
        self.backgroundColor = .darkGray
        self.textColor = .selectedTextColor
        super.draw(withFrame: cellFrame, in: controlView)
    }
    
}
