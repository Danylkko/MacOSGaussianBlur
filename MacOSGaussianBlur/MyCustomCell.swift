//
//  MyCustomCell.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 12.06.2022.
//

import Cocoa

class MyCustomCell: NSButtonCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
        self.bezelStyle = .texturedSquare
        self.isBordered = true
        self.showsBorderOnlyWhileMouseInside = true
    }
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        let path = NSBezierPath(roundedRect: frame, xRadius: 4, yRadius: 4)
        NSColor.lightGray.withAlphaComponent(0.5).set()
        path.stroke()
    }
    
}
