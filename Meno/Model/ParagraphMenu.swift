//
//  ParagraphMenu.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/01.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class ParagraphMenu: NSMenu {
    var captionMenuItem: NSMenuItem!
    var textMenuItem: NSMenuItem!
    var listMenuItem: NSMenuItem!
    var numberListMenuItem: NSMenuItem!
    
    var paragraphStyle: ParagraphStyle = .text
    private var _paragraphMenuDelegate: ParagraphMenuDelegate?
    
    override init(title: String) {
        
        super.init(title: title)
        
        commonInit()
    }

    required init(coder decoder: NSCoder) {
        
        super.init(coder: decoder)
        
        commonInit()
    }
    
    func commonInit() {
        let fontManager = NSFontManager.shared
        
        self.minimumWidth = 200
        
        captionMenuItem = NSMenuItem(title: "見出し", action: #selector(self.menuAction(_:)), keyEquivalent: "")
        captionMenuItem.target = self
        captionMenuItem.state = .off
        captionMenuItem.image = NSImage(size: NSMakeSize(1,30))
        let captionStr = NSMutableAttributedString(string: "見出し")
        var captionFont = NSFont.systemFont(ofSize: 20)
        captionFont = fontManager.convert(captionFont, toHaveTrait: [.boldFontMask])
        captionStr.addAttribute(.font, value: captionFont, range: NSMakeRange(0, captionStr.length))
        captionMenuItem.attributedTitle = captionStr
        
        textMenuItem = NSMenuItem(title: "本文", action: #selector(self.menuAction(_:)), keyEquivalent: "")
        textMenuItem.target = self
        textMenuItem.state = .off
        textMenuItem.image = NSImage(size: NSMakeSize(1,25))
        let textStr = NSMutableAttributedString(string: "本文")
        let textFont = NSFont.systemFont(ofSize: 13)
        textStr.addAttribute(.font, value: textFont, range: NSMakeRange(0, textStr.length))
        textMenuItem.attributedTitle = textStr
        
        listMenuItem = NSMenuItem(title: "箇条書き", action: #selector(self.menuAction(_:)), keyEquivalent: "")
        listMenuItem.target = self
        listMenuItem.state = .off
        listMenuItem.image = NSImage(size: NSMakeSize(1,25))
        let listFont = NSFont.systemFont(ofSize: 13)
        let list = NSTextList(markerFormat: NSTextList.MarkerFormat(" {disc} "), options: 0)
        let paragraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraph.textLists.append(list)
        let listAttributes = [NSAttributedStringKey.paragraphStyle: paragraph, NSAttributedStringKey.font: listFont]
        let listStr = NSMutableAttributedString(string: NSString(format: "%@箇条書き", list.marker(forItemNumber: 1)) as String, attributes: listAttributes)
        listMenuItem.attributedTitle = listStr
        
        numberListMenuItem = NSMenuItem(title: "番号付き箇条書き", action: #selector(self.menuAction(_:)), keyEquivalent: "")
        numberListMenuItem.target = self
        numberListMenuItem.state = .off
        numberListMenuItem.image = NSImage(size: NSMakeSize(1,25))
        let numberFont = NSFont.systemFont(ofSize: 13)
        let numberList = NSTextList(markerFormat: NSTextList.MarkerFormat(" {decimal}. "), options: 1)
        let numberParagraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        numberParagraph.textLists.append(numberList)
        let numberAttributes = [NSAttributedStringKey.paragraphStyle: paragraph, NSAttributedStringKey.font: numberFont]
        let numberStr = NSMutableAttributedString(string: NSString(format: "%@箇条書き", numberList.marker(forItemNumber: 1)) as String, attributes: numberAttributes)
        numberListMenuItem.attributedTitle = numberStr
        
        self.addItem(captionMenuItem)
        self.addItem(textMenuItem)
        self.addItem(listMenuItem)
        self.addItem(numberListMenuItem)
    }
    
    @objc func menuAction(_ sender: Any?) {
//        self.captionMenuItem.state = .off
//        self.textMenuItem.state = .off
//        self.listMenuItem.state = .off
//        self.numberListMenuItem.state = .off
        
        let clickedItem = sender as! NSMenuItem
        //clickedItem.state = .on
        
        if clickedItem === captionMenuItem {
            self.paragraphStyle = .caption
        } else if clickedItem === textMenuItem {
            self.paragraphStyle = .text
        } else if clickedItem === listMenuItem {
            self.paragraphStyle = .list
        } else if clickedItem === numberListMenuItem {
            self.paragraphStyle = .numberList
        }
        
        self.paragraphMenuDelegate?.paragraphMenuItemSelected()
    }
    
    var paragraphMenuDelegate: ParagraphMenuDelegate?
}

protocol ParagraphMenuDelegate: class {
    func paragraphMenuItemSelected()
}
