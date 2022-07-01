//
//  MyCustomCell.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 12.06.2022.
//

import Cocoa

class MyNSButtonCell: NSButtonCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
        self.bezelStyle = .texturedSquare
        self.isBordered = true
        self.showsBorderOnlyWhileMouseInside = true
    }
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        let path = NSBezierPath(roundedRect: frame, xRadius: 4, yRadius: 4)
        NSColor.darkGray.withAlphaComponent(0.5).set()
        path.fill()
    }
    
//    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
//
//        let colorTitle = NSMutableAttributedString(attributedString: title)
//        let titleRange = NSRange(location: 0, length: colorTitle.length)
//        colorTitle.addAttribute(.foregroundColor, value: NSColor.lightGray, range: titleRange)
//        return super.drawTitle(colorTitle, withFrame: frame, in: controlView)
//    }
    
}
