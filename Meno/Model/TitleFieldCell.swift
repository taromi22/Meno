//
//  TitleFieldCell.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/12/24.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class TitleFieldCell: NSTextFieldCell {
    let padding: NSSize = NSMakeSize(8.0, 4.0)
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        let path = NSBezierPath(roundedRect: cellFrame, xRadius: 5.0, yRadius: 5.0)
        path.addClip()
        
        super.draw(withFrame: cellFrame, in: controlView)
        
        path.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
        path.lineWidth = 2
        NSColor.gray.setStroke()
        path.stroke()
    }
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let rectInset = rect.insetBy(dx: padding.width, dy: padding.height)
        
        return super.drawingRect(forBounds: rectInset)
    }
    
    override func titleRect(forBounds rect: NSRect) -> NSRect {
        let rectInset = rect.insetBy(dx: padding.width, dy: padding.height)
        
        return super.titleRect(forBounds: rectInset)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let rectInset = rect.insetBy(dx: padding.width, dy: padding.height)
        
        super.select(withFrame: rectInset, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let rectInset = rect.insetBy(dx: padding.width, dy: padding.height)
        
        super.edit(withFrame: rectInset, in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
}
