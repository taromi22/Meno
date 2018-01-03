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
        
        captionMenuItem = NSMenuItem(title: "見出し", action: #selector(self.menuAction(_:)), keyEquivalent: "")
        captionMenuItem.target = self
        captionMenuItem.state = .off
        let label = NSTextField(labelWithString: "見出し")
        var font = NSFont.systemFont(ofSize: 24)
        font = fontManager.convert(font, toHaveTrait: [.boldFontMask])
        label.font = font
        captionMenuItem.view = label
        label.frame = NSMakeRect(label.frame.origin.x, label.frame.origin.y, 150, 20)
        textMenuItem = NSMenuItem(title: "本文", action: #selector(self.menuAction(_:)), keyEquivalent: "")
        textMenuItem.target = self
        textMenuItem.state = .off
        listMenuItem = NSMenuItem(title: "箇条書き", action: #selector(self.menuAction(_:)), keyEquivalent: "")
        listMenuItem.target = self
        listMenuItem.state = .off
        numberListMenuItem = NSMenuItem(title: "番号付き箇条書き", action: #selector(self.menuAction(_:)), keyEquivalent: "")
        numberListMenuItem.target = self
        numberListMenuItem.state = .off
        
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
