//
//  TitleField.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/12/24.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class TitleField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        var rect = NSMakeRect(0.0, 0.0, self.bounds.width, self.bounds.height)
        // 太くなるのを防ぐため0.5内側をとる
        rect = rect.insetBy(dx: 0.5, dy: 0.5)
        
        let path = NSBezierPath(roundedRect: rect, xRadius: 8.0, yRadius: 8.0)
        path.lineWidth = 1.0
        NSColor(calibratedWhite: 1.0, alpha: 0.394).set()
        path.fill()
        NSColor.gray.set()
        path.stroke()
        
        if let window = self.window {
            if window.firstResponder == self.currentEditor() && NSApp.isActive {
                NSGraphicsContext.saveGraphicsState()
                NSFocusRingPlacement.only.set()
                path.fill()
                NSGraphicsContext.restoreGraphicsState()
            } else {
                self.attributedStringValue.draw(in: rect)
            }
        }
    }
    
}
