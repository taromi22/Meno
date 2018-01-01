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
                    let selectedRange = textView.selectedRange()
                    
                    if selectedRange.length > 0 {
                        var sameFontRange = NSMakeRange(0, 0)
                        var isBoldfornow = false
                        
                        storage.enumerateAttribute(.font, in: selectedRange, options: .longestEffectiveRangeNotRequired, using: { (value, range, stop) in
                            if let font = value as? NSFont {
                                if fontManager.traits(of: font).contains(.boldFontMask) {
                                    isBoldfornow = true
                                    stop.pointee = false
                                } else {
                                    isBoldfornow = false
                                    stop.pointee = true
                                }
                            }
                        })
                        self.isBold = isBoldfornow
                        
                        var isItalicfornow = false
                        
                        storage.enumerateAttribute(.font, in: selectedRange, options: .longestEffectiveRangeNotRequired, using: { (value, range, stop) in
                            if let font = value as? NSFont {
                                if fontManager.traits(of: font).contains(.italicFontMask) {
                                    isItalicfornow = true
                                    stop.pointee = false
                                } else {
                                    isItalicfornow = false
                                    stop.pointee = true
                                }
                            }
                        })
                        self.isItalic = isItalicfornow
                        
                        if let underlineStyle = storage.attribute(.underlineStyle, at: selectedRange.location, longestEffectiveRange: &sameFontRange, in: selectedRange) as? Int {
                            
                            if underlineStyle != 0 &&
                               selectedRange == sameFontRange {
                                self.isUnderline = true
                            } else {
                                self.isUnderline = false
                            }
                        } else {
                            self.isUnderline = false
                        }
                    } else {
                        if let font = textView.typingAttributes[.font] as? NSFont {
            
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
                        } else {
                            self.isBold = false
                            self.isItalic = false
                        }
                            
                        if let underlineStyle = textView.typingAttributes[.underlineStyle] as? Int {
                            if underlineStyle != 0 {
                                self.isUnderline = true
                            } else {
                                self.isUnderline = false
                            }
                        } else {
                            self.isUnderline = false
                        }
                    }
                })
            }
        }
    }
    var boldButton: NSButton? {
        didSet {
            boldButton?.target = self
        }
    }
    var italicButton: NSButton? {
        didSet {
            italicButton?.target = self
        }
    }
    var underlineButton: NSButton? {
        didSet {
            underlineButton?.target = self
        }
    }
    
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
    var isUnderline: Bool = false {
        didSet {
            if isUnderline {
                self.underlineButton?.state = .on
                self.underlineButton?.action = #selector(self.removeUnderline)
            } else {
                self.underlineButton?.state = .off
                self.underlineButton?.action = #selector(self.addUnderline)
            }
        }
    }
    
    @objc func addUnderline() {
        if let textView = self.targetTextView,
           let storage = textView.textStorage {
            
            let range = textView.selectedRange()
            
            if range.length == 0 {
                textView.typingAttributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
            } else {
                storage.addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue , range: textView.selectedRange())
            }
        }
    }
    @objc func removeUnderline() {
        
        if let textView = self.targetTextView,
           let storage = textView.textStorage {
            
            let range = textView.selectedRange()
            
            if range.length == 0 {
                textView.typingAttributes[.underlineStyle] = 0
            } else {
                storage.removeAttribute(.underlineStyle, range: textView.selectedRange())
            }
        }
    }
}
