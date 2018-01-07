//
//  Note.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/17.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//


import Cocoa

class NoteProfile: NSObject, NSPasteboardWriting, NSPasteboardReading, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    
    static var pasteboardTypeNoteProfile: NSPasteboard.PasteboardType = .init("meno.profile")
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(string, forKey: "string")
        aCoder.encode(updatedDate, forKey: "updatedDate")
        aCoder.encode(createdDate, forKey: "createdDate")
        aCoder.encode(order, forKey: "order")
    }
    
    
    @objc var id: Int32
    @objc var title: String {
        //  titleForPresentationの変更通知を手動で呼ぶ
        willSet {
            self.willChangeValue(forKey: "titleForPresentation")
        }
        didSet {
            self.didChangeValue(forKey: "titleForPresentation")
        }
    }
    @objc var string: String
    @objc var updatedDate: Date {
        willSet {
            self.willChangeValue(forKey: "updatedDate")
        }
        didSet {
            self.didChangeValue(forKey: "updatedDate")
        }
    }
    @objc var createdDate: Date
    @objc var order: Int32
    @objc var titleForPresentation: String {
        get {
            if self.title == "" {
                return "タイトルなし"
            } else {
                return self.title
            }
        }
    }
    
    init(id: Int32, title: String, string: String, updatedDate: Date, createdDate: Date, order: Int32) {
        self.id = id
        self.title = title
        self.string = string
        self.updatedDate = updatedDate
        self.createdDate = createdDate
        self.order = order
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInt32(forKey: "id")
        self.title = aDecoder.decodeObject(of: NSString.self, forKey: "title")! as String
        self.string = aDecoder.decodeObject(of: NSString.self, forKey: "string")! as String
        self.updatedDate = aDecoder.decodeObject(of: NSDate.self, forKey: "updatedDate")! as Date
        self.createdDate = aDecoder.decodeObject(of: NSDate.self, forKey: "createdDate")! as Date
        self.order = aDecoder.decodeInt32(forKey: "order")
    }
    
    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        return nil
    }
    
    
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [NoteProfile.pasteboardTypeNoteProfile]
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        if type == NoteProfile.pasteboardTypeNoteProfile {
            return NSKeyedArchiver.archivedData(withRootObject: self)
        }
        return nil
    }
    static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [NoteProfile.pasteboardTypeNoteProfile]
    }
    static func readingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
        return .asKeyedArchive
    }
}
