//
//  TextViewAttributeObserver.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/01.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

// TextViewのAttributeを監視し，自作のフォント操作ボタン等の管理を行う．
class TextViewAttributeObserver: NSObject {
    
    var targetTextView: NSTextView? {
        didSet {
            if let textView = targetTextView {
                NotificationCenter.default.addObserver(forName: NSTextView.didChangeSelectionNotification, object: textView, queue: OperationQueue.main, using: textViewSelectionChanged)
            }
        }
    }
    // 代入すると太字ボタンとして登録される．ボタンのtagを2に設定しておくことが必要．
    var boldButton: NSButton? {
        didSet {
            boldButton?.target = self
            boldButton?.action = #selector(self.bold)
        }
    }
    // 代入するとイタリックボタンとして登録される．ボタンのtagを1に設定しておくことが必要．
    var italicButton: NSButton? {
        didSet {
            italicButton?.target = self
            italicButton?.action = #selector(self.italic)
        }
    }
    // 代入すると下線ボタンとして登録される．
    var underlineButton: NSButton? {
        didSet {
            //underlineButton?.target = self
            //underlineButton?.action = #selector(self.underline)
        }
    }
    var paragraphMenu: ParagraphMenu? {
        didSet {
            if let menu = paragraphMenu {
                menu.paragraphMenuDelegate = self
            }
        }
    }
    // TextViewの現在のキャレット位置が太字フォントかどうか．セットするとボタンのオンオフが連動する．
    // ここから操作してもフォントは切り替わらない．
    var isBold: Bool = false {
        didSet {
            if isBold {
                self.boldButton?.state = .on
            } else {
                self.boldButton?.state = .off
            }
        }
    }
    // TextViewの現在のキャレット位置がイタリックフォントかどうか．セットするとボタンのオンオフが連動する．
    // ここから操作してもフォントは切り替わらない．
    private(set) var isItalic: Bool = false {
        didSet {
            // ボタンのオンオフを切り替え
            if isItalic {
                self.italicButton?.state = .on
            } else {
                self.italicButton?.state = .off
            }
        }
    }
    // TextViewの現在のキャレット位置が下線ありかどうか．セットするとボタンのオンオフが連動する．
    // ここから操作してもフォントは切り替わらない．
    var isUnderline: Bool = false {
        didSet {
            if isUnderline {
                self.underlineButton?.state = .on
            } else {
                self.underlineButton?.state = .off
            }
        }
    }
    // TextViewの現在のキャレット位置の段落スタイル．
    var paragraphStyle: ParagraphStyle = ParagraphStyle.text {
        didSet {
        }
    }
    
    func textViewSelectionChanged(notif: Notification) {
        
        // 太字・イタリックの判別
        let fontManager = NSFontManager.shared
        
        if let font = fontManager.selectedFont {
            
            let traitMask = fontManager.traits(of: font)
            
            self.isBold = traitMask.contains(.boldFontMask)
            self.isItalic = traitMask.contains(.italicFontMask)
        }
        
        // 下線の判別
        
        if let textView = targetTextView,
            let storage = textView.textStorage {
            
            let selectedRange = textView.selectedRange()
            
            if selectedRange.length > 0 {
                var allUnderlined = true
                
                storage.enumerateAttribute(.underlineStyle, in: selectedRange, options: .longestEffectiveRangeNotRequired, using: { (value, range, stop) in
                    
                    if let underlineStyle = value as? Int {
                        
                        if underlineStyle == 0 {
                            
                            allUnderlined = false
                            stop.pointee = true
                        }
                    } else {
                        allUnderlined = false
                        stop.pointee = true
                    }
                })
                
                self.isUnderline = allUnderlined
                
            } else {
                if let underlineStyle = textView.typingAttributes[.underlineStyle] as? Int {
                    
                    self.isUnderline = (underlineStyle != 0)
                } else {
                    
                    self.isUnderline = false
                }
            }
        }
    }
    
    @objc func bold() {
        let fontManager = NSFontManager.shared
        
        if self.isBold {
            fontManager.removeFontTrait(self.boldButton)
        } else {
            fontManager.addFontTrait(self.boldButton)
        }
        
        self.isBold = !self.isBold
    }
    @objc func italic() {
        let fontManager = NSFontManager.shared
        
        if self.isItalic {
            fontManager.removeFontTrait(self.italicButton)
        } else {
            fontManager.addFontTrait(self.italicButton)
        }
        
        self.isItalic = !self.isItalic
    }
    @objc func underline() {
        if let textView = self.targetTextView {
            
            textView.underline(self)
            
            self.isUnderline = !self.isUnderline
        }
    }
}

extension TextViewAttributeObserver: ParagraphMenuDelegate {
    func paragraphMenuItemSelected() {
        self.paragraphStyle = self.paragraphMenu!.paragraphStyle
        if let textView = self.targetTextView,
            let storage = textView.textStorage {
        
            let fontManager = NSFontManager.shared
            let selectedRange = textView.selectedRange()
            // 段落全体を取得
            let range = (self.targetTextView!.string as NSString).paragraphRange(for: selectedRange)
        
            switch self.paragraphStyle {
            case .caption:
                let paragraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                var font = NSFont.systemFont(ofSize: 20.0)
                font = fontManager.convert(font, toHaveTrait: [.boldFontMask])
                
                storage.addAttribute(.paragraphStyle, value: paragraph, range: range)
                storage.addAttribute(.font, value: font, range: range)
            
            case .text:
                let paragraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                let font = NSFont.systemFont(ofSize: 13.0)
                
                storage.addAttribute(.paragraphStyle, value: paragraph, range: range)
                storage.addAttribute(.font, value: font, range: range)
                
            case .list:
                let font = NSFont.systemFont(ofSize: 13)
                let list = NSTextList(markerFormat: NSTextList.MarkerFormat("{disc}"), options: 0)
                let paragraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                
                if paragraph.textLists.count > 0 {
                    return
                }
                
                paragraph.textLists = [list]
                let attributes = [NSAttributedStringKey.paragraphStyle: paragraph, NSAttributedStringKey.font: font]
                storage.insert(NSAttributedString(string: " \(list.marker(forItemNumber: 0))\t"), at: range.location)
                
                let listRange = NSMakeRange(range.location, range.length + 3)
                storage.addAttributes(attributes, range: listRange)
                
            default:
                break
            }
        }
    }
}

enum ParagraphStyle {
    case caption
    case text
    case list
    case numberList
}
