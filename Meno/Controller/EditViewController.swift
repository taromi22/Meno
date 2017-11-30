//
//  EditViewController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/15.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class EditViewController: NSViewController {
    
    @IBOutlet var textView: MTextView!
    
    var dbManager: DBManager?
    var showingId: Int?
    var text: String {
        return self.textView.string
    }
    var textStorage: NSTextStorage? {
        return self.textView.textStorage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.textContainerInset = NSSize(width: 20.0, height: 36.0)
    }
    
    func saveAndReload(id: Int) {
        // 保存処理
        if let preId = self.showingId {
            do {
                let data = try self.textStorage!.data(from: NSRange(location: 0, length: self.textStorage!.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
                let stringdata = String(data: data, encoding: .utf8) ?? ""
                dbManager!.saveNote(id: preId, content: stringdata)
            } catch { }
        }
        // 表示
        let newstringdata = dbManager!.getNote(id: id)
        if let newdata = newstringdata.data(using: .utf8) {
            if let attr_string = NSAttributedString(rtf: newdata, documentAttributes: nil) {
                self.textStorage!.setAttributedString(attr_string)
            } else {
                self.textStorage!.setAttributedString(NSAttributedString(string: ""))
            }
        }
        self.showingId = id
        
    }
}
