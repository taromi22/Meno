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
            let minWidth = oldValue.width
            let minHeight = oldValue.height
            
            var newWidth: CGFloat = self.frame.width
            var newHeight: CGFloat = self.frame.height
            
            // 現在のサイズがminSizeを下回っていたら引き伸ばす
            if self.frame.width < minWidth {
                newWidth = minWidth
            }
            if self.frame.height < minHeight {
                newHeight = minHeight
            }
            self.frame = NSMakeRect(0.0, 0.0, newWidth, newHeight)
            
            // textViewも引き伸ばす
            textView.minSize = NSMakeSize(0.0, minHeight - self.headerHeight)
            
            textView.frame = NSMakeRect(0.0, 0.0, self.frame.width, self.frame.height - self.headerHeight)
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
        dateField.stringValue = "2017年12月22日 (金)"
        self.addSubview(dateField)
        
        // タイトルフィールド
        titleField = NSTextField(frame: NSMakeRect(frameRect.origin.x + titleMargin.width, frameRect.height - (dateHeight + titleHeight + titleMargin.height), frameRect.width - titleMargin.width*2, self.titleHeight))
        titleField.cell = TitleFieldCell()
        titleField.backgroundColor = .white
        titleField.isEnabled = true
        titleField.isEditable = true
        titleField.isSelectable = true
        titleField.autoresizingMask = [.width, .minYMargin]
        titleField.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        titleField.delegate = self
        self.addSubview(titleField)
        
        // コンテンツビュー
        textView = MTextView(frame: NSMakeRect(0, 0, frameRect.width, frameRect.height - self.headerHeight))
        textView.minSize = NSMakeSize(0.0, frameRect.height - self.headerHeight)
        textView.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width, .minYMargin]
        textView.textContainer?.containerSize = NSMakeSize(frameRect.width, CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainerInset = NSSize(width: 20.0, height: 10.0)
        textView.importsGraphics = true
        textView.controller = self.controller
        self.addSubview(textView)
        
        // textViewのサイズ変更を監視し，それに合わせてサイズ変更
        NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: textView, queue: OperationQueue.main) { (notif) in
            var newHeight: CGFloat = self.frame.height
            
            if self.frame.height - self.titleHeight != self.textView.frame.height {
                newHeight = self.textView.frame.height + self.headerHeight
            }
            
            self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.width, newHeight)
            
            // 読み込み後の場合はトップまでスクロール (SelectedRangeをフラグとして用いている)
            if self.textView.selectedRange() == NSMakeRange(0, 0) {
                self.scroll(NSMakePoint(0.0, self.frame.height))
            }
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
        
        // あとでminSize変えてるから必要？
        self.frame.size = NSMakeSize(self.minSize.width, self.frame.height)
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
