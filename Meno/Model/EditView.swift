//
//  EditView.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/12/10.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class EditView: NSView {
    let dateHeight: CGFloat = 20.0
    let titleHeight: CGFloat = 38.0
    let titleMargin: NSSize = NSMakeSize(8.0, 8.0)
    
    let titleFontSize: CGFloat = 24.0
    let mainFontSize: CGFloat = 13.0
    
    var controller: EditViewController! {
        didSet {
            if let textView = self.textView {
                textView.controller = self.controller
            }
        }
    }
    var headerHeight: CGFloat {
        get {
            return dateHeight + titleHeight + titleMargin.height*2
        }
    }
    
    var delegate: EditViewDelegate?
    var dateField: NSTextField!
    var titleField: NSTextField!
    var textView: MTextView!
    var minSize: NSSize = NSMakeSize(0, 0) {
        didSet {
            var newWidth: CGFloat = self.frame.width
            var newHeight: CGFloat = self.frame.height
            
            // 現在のサイズがminSizeを下回っていたら引き伸ばす
            if self.frame.width < self.minSize.width {
                newWidth = self.minSize.width
            }
            if self.frame.height < self.minSize.width {
                newHeight = self.minSize.height
            }
            self.frame.size = NSMakeSize(newWidth, newHeight)
            
            // textViewも引き伸ばす
            textView.minSize = NSMakeSize(0.0, self.minSize.height - self.headerHeight)
            
            textView.frame = NSMakeRect(0.0, 0.0, max(textView.frame.width, self.minSize.width), max(textView.frame.height, self.minSize.height))
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // 日時ラベル
        dateField = NSTextField(frame: NSMakeRect(frameRect.origin.x, frameRect.height - self.dateHeight, frameRect.width, dateHeight))
        dateField.autoresizingMask = [.width, .minYMargin]
        dateField.textColor = NSColor.gray
        dateField.isBordered = false
        dateField.isEditable = false
        dateField.alignment = .center
        self.addSubview(dateField)
        
        // タイトルフィールド
        titleField = NSTextField(frame: NSMakeRect(frameRect.origin.x + titleMargin.width, frameRect.height - (dateHeight + titleHeight + titleMargin.height), frameRect.width - titleMargin.width*2, self.titleHeight))
        titleField.cell = TitleFieldCell()
        titleField.backgroundColor = .white
        titleField.isEnabled = true
        titleField.isEditable = true
        titleField.isSelectable = true
        titleField.autoresizingMask = [.width, .minYMargin]
        titleField.font = NSFont.systemFont(ofSize: self.titleFontSize, weight: .heavy)
        titleField.delegate = self
        self.addSubview(titleField)
        
        // コンテンツビュー
        textView = MTextView(frame: NSMakeRect(0, 0, frameRect.width, frameRect.height - self.headerHeight))
        textView.minSize = NSMakeSize(0.0, frameRect.height - self.headerHeight)
        textView.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width, .minYMargin]
        textView.font = NSFont.systemFont(ofSize: self.mainFontSize)
        textView.textContainer?.containerSize = NSMakeSize(frameRect.width, CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainerInset = NSSize(width: 20.0, height: 10.0)
        textView.importsGraphics = true
        textView.controller = self.controller
        self.addSubview(textView)
        
        // textViewのサイズ変更を監視し，それに合わせてサイズ変更
        NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: textView, queue: OperationQueue.main) { (notif) in
            
            let newHeight: CGFloat = max(self.textView.frame.height + self.headerHeight, self.minSize.height)
            let dHeight: CGFloat = newHeight - self.frame.height
            
            if self.frame.height != newHeight {
                self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y - dHeight, self.frame.width, newHeight)
            }
    
            self.textView.frame.origin = NSMakePoint(0, 0)
        }
        // textViewの内容が変更されたらdelegateに通知
        NotificationCenter.default.addObserver(forName: NSTextView.didChangeNotification, object: textView, queue: OperationQueue.main) { (notif) in
            self.delegate?.editViewContentChanged()
        }
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    /// リサイズしたときにminSizeを引き伸ばすor縮める
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
        
        let dWidth = self.superview!.frame.width - oldSize.width
        let dHeight = self.superview!.frame.height - oldSize.height
        
        self.minSize = NSMakeSize(self.minSize.width + dWidth, self.minSize.height + dHeight)
    }
}

extension EditView: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        delegate?.editViewTitleChanged(string: self.titleField.stringValue)
    }
}

protocol EditViewDelegate: class {
    func editViewTitleChanged(string: String)
    func editViewContentChanged()
}
