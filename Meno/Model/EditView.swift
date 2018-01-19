//
//  EditView.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/12/10.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class EditView: NSView {
    let dateHeight: CGFloat = 22.0
    let titleHeight: CGFloat = 38.0
    let dateMargin: NSSize = NSMakeSize(0.0, 3.0)
    let titleMargin: NSSize = NSMakeSize(8.0, 5.0)
    let transitionButtonWidth: CGFloat = 100.0
    
    let titleFontSize: CGFloat = 24.0
    let mainFontSize: CGFloat = 13.0
    
    var dbManager: DBManager! {
        didSet {
            if let textView = self.textView {
                textView.dbManager = self.dbManager
            }
        }
    }
    var headerHeight: CGFloat {
        get {
            return dateHeight + titleHeight + dateMargin.height*2 + titleMargin.height*2
        }
    }
    var isBackButtonHidden: Bool = false{
        didSet {
            self.backButton.isHidden = self.isBackButtonHidden
        }
    }
    var backButtonText: String? {
        get {
            return self.backButton.title
        }
        set {
            self.backButton.title = newValue ?? ""
        }
    }
    
    var delegate: EditViewDelegate?
    var dateField: NSTextField!
    var titleField: NSTextField!
    var backButton: NSButton!
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
        dateField = NSTextField(frame: NSMakeRect(frameRect.origin.x + self.dateMargin.width + self.transitionButtonWidth, frameRect.height - self.dateHeight - self.dateMargin.height, frameRect.width - self.dateMargin.width*2 - self.transitionButtonWidth*2, self.dateHeight))
        dateField.autoresizingMask = [.width, .minYMargin]
        dateField.textColor = NSColor.gray
        dateField.isBordered = false
        dateField.isEditable = false
        dateField.alignment = .center
        self.addSubview(self.dateField)
        // 戻るボタン
        backButton = NSButton(frame: NSMakeRect(frameRect.origin.x + self.dateMargin.width, frameRect.height - self.dateHeight - self.dateMargin.height, self.transitionButtonWidth, self.dateHeight))
        backButton.autoresizingMask = [.maxXMargin, .minYMargin]
        backButton.title = "< 戻る"
        backButton.setButtonType(.momentaryLight)
        backButton.bezelStyle = .regularSquare
        backButton.target = self
        backButton.isHidden = true
        backButton.action = #selector(self.backButtonClicked)
        self.addSubview(self.backButton)
        
        // タイトルフィールド
        titleField = NSTextField(frame: NSMakeRect(frameRect.origin.x + self.titleMargin.width, frameRect.height - (self.dateHeight + self.dateMargin.height*2 + titleHeight + self.titleMargin.height), frameRect.width - self.titleMargin.width*2, self.titleHeight))
        titleField.cell = TitleFieldCell()
        titleField.backgroundColor = .white
        titleField.isEnabled = true
        titleField.isEditable = true
        titleField.isSelectable = true
        titleField.autoresizingMask = [.width, .minYMargin]
        titleField.font = NSFont.systemFont(ofSize: self.titleFontSize, weight: .heavy)
        titleField.delegate = self
        self.addSubview(self.titleField)
        
        // コンテンツビュー
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: .zero)
        layoutManager.addTextContainer(textContainer)
        textView = MTextView(frame: NSMakeRect(0, 0, frameRect.width, frameRect.height - self.headerHeight), textContainer: textContainer)
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
        textView.dbManager = self.dbManager
        textView.mTextViewDelegate = self
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
    
    @objc func backButtonClicked() {
        self.delegate?.editViewBackButtonClicked()
    }
}

extension EditView: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        delegate?.editViewTitleChanged(string: self.titleField.stringValue)
    }
}

extension EditView: MTextViewDelegate {
    func mTextViewNoteAttachmentCellInvoked(profile: NoteProfile) {
        self.delegate?.editViewNoteCellTriggered(profile: profile)
    }
}

protocol EditViewDelegate: class {
    func editViewTitleChanged(string: String)
    func editViewContentChanged()
    func editViewBackButtonClicked()
    func editViewNoteCellTriggered(profile: NoteProfile)
}
