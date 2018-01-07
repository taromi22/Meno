//
//  BulletListLayoutManager.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/05.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class BulletListLayoutManager: NSLayoutManager {
    let bulletSize = CGSize(width: 8, height: 8)
    let bulletColor = NSColor.black
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        
        enumerateLineFragments(forGlyphRange: glyphsToShow) { (rect, usedRect, textContainer, glyphRange, _) in
            let origin = CGPoint(x: origin.x + usedRect.origin.x, y: origin.y + usedRect.origin.y + (usedRect.size.height - self.bulletSize.height / 2))
            
            self.bulletColor.setFill()
            NSColor.red.set()
            NSBezierPath(rect: usedRect).fill()
            NSBezierPath(ovalIn: CGRect(origin: origin, size: self.bulletSize)).fill()
        }
    }
}
