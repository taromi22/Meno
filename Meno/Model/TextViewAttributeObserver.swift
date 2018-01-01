//
//  TextViewAttributeObserver.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/01.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class TextViewAttributeObserver: NSObject {
    var targetTextView: NSTextView? {
        didSet {
            if let textView = targetTextView,
               let storage = textView.textStorage {
                
                NotificationCenter.default.addObserver(forName: NSTextView.didChangeSelectionNotification, object: textView, queue: OperationQueue.main, using: { (notif) in
                    let fontManager = NSFontManager.shared
                    let range = textView.selectedRange()
                    
                    if range.length > 0 {
                        var sameFontRange = NSMakeRange(0, 0)
                        let font = storage.attribute(.font, at: range.location, longestEffectiveRange: &sameFontRange, in: range) as! NSFont
                        
                        if fontManager.traits(of: font).contains(.boldFontMask) &&
                           range == sameFontRange {
                            self.isBold = true
                        } else {
                            self.isBold = false
                        }
                        if fontManager.traits(of: font).contains(.italicFontMask) &&
                            range == sameFontRange {
                            self.isItalic = true
                        } else {
                            self.isItalic = false
                        }
                    } else {
                        let font = textView.typingAttributes[.font] as! NSFont
                        
                        if fontManager.traits(of: font).contains(.boldFontMask) {
                            self.isBold = true
                        } else {
                            self.isBold = false
                        }
                        if fontManager.traits(of: font).contains(.italicFontMask) {
                            self.isItalic = true
                        } else {
                            self.isItalic = false
                        }
                    }
                })
            }
        }
    }
    var boldButton: NSButton?
    var italicButton: NSButton?
    
    var isBold: Bool = false {
        didSet {
            let fontManager = NSFontManager.shared
            
            if isBold {
                self.boldButton?.state = .on
                self.boldButton?.action = #selector(fontManager.removeFontTrait(_:))
            } else {
                self.boldButton?.state = .off
                self.boldButton?.action = #selector(fontManager.addFontTrait(_:))
            }
        }
    }
    var isItalic: Bool = false {
        didSet {
            let fontManager = NSFontManager.shared
            
            if isItalic {
                self.italicButton?.state = .on
                self.italicButton?.action = #selector(fontManager.removeFontTrait(_:))
            } else {
                self.italicButton?.state = .off
                self.italicButton?.action = #selector(fontManager.addFontTrait(_:))
            }
        }
    }
}
