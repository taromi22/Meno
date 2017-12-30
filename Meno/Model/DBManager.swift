//
//  DBManager.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/17.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa
import FMDB

class DBManager: NSObject {
    var db: FMDatabase? = nil
    private(set) var filePath: String?
    private(set) var currentDirectory: String?
    
    func open(url: URL, completed: (Bool) -> Void) {
        db = FMDatabase(url: url)
        
        let result = db!.open()
        
        if result {
            self.filePath = url.path
            self.currentDirectory = filePath?.deletingLastPathComponent
        }
        completed(result)
    }
    
    func getProfile() -> [NoteProfile] {
        let results = db?.executeQuery("SELECT ID, TITLE, STRING, DATE_UPDATE, DATE_CREATE, ORDER_NUMBER FROM ITEMS", withParameterDictionary: nil)
        var profiles: [NoteProfile] = []
        
        if let results = results {
            while results.next() {
                let title = results.string(forColumn: "TITLE") ?? ""
                let id = results.int(forColumn: "ID")
                let string = results.string(forColumn: "STRING") ?? ""
                let updatedDate = results.date(forColumn: "DATE_UPDATE") ?? Date()
                let createdDate = results.date(forColumn: "DATE_CREATE") ?? Date()
                let order = results.int(forColumn: "ORDER_NUMBER")
                
                profiles.append(NoteProfile(id: id, title: title, string: string, updatedDate: updatedDate, createdDate: createdDate, order: order))
            }
        }
        
        return profiles
    }
    
    func getProfile(id: Int32) -> NoteProfile? {
        let results = db?.executeQuery("SELECT ID, TITLE, STRING, DATE_UPDATE, DATE_CREATE, ORDER_NUMBER FROM ITEMS", withParameterDictionary: nil)
        
        if let results = results {
            results.next()
            let id = results.int(forColumn: "ID")
            let title = results.string(forColumn: "TITLE") ?? ""
            let string = results.string(forColumn: "STRING") ?? ""
            let updatedDate: Date = results.date(forColumn: "DATE_UPDATE") ?? Date()
            let createdDate: Date = results.date(forColumn: "DATE_CREATE") ?? Date()
            let order = results.int(forColumn: "ORDER_NUMBER")
            
            return NoteProfile(id: id, title: title, string: string, updatedDate: updatedDate, createdDate: createdDate, order: order)
        }
        
        return nil
    }
    
    func saveProfile(profile: NoteProfile) {
        db!.executeUpdate("UPDATE ITEMS SET TITLE=?, STRING=?, DATE_UPDATE=?, DATE_CREATE=?, ORDER_NUMBER=? WHERE ID=?", withArgumentsIn: [profile.title, profile.string, profile.updatedDate as NSDate, profile.createdDate as NSDate, profile.order, profile.id])
    }
    
    func getNote(id: Int32) -> NSAttributedString? {
        let results = db?.executeQuery("SELECT CONTENT FROM ITEMS WHERE ID=\(id)", withParameterDictionary: nil)
        
        if let results = results {
            results.next()
            if let data = results.data(forColumn: "CONTENT") {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSAttributedString
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    @discardableResult
    func saveNote(id: Int32, content: NSAttributedString) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: content)
        
        return db!.executeUpdate("UPDATE ITEMS SET CONTENT=? WHERE ID=\(id)", withArgumentsIn: [data])
    }
    
    func addNew() -> Int32? {
        if db!.executeUpdate("INSERT INTO ITEMS(TITLE, CONTENT, STRING, DATE_UPDATE, DATE_CREATE) VALUES(?, ?, ?, ?, ?)", withArgumentsIn: ["", NSKeyedArchiver.archivedData(withRootObject: NSAttributedString()), "", NSDate(), NSDate()]) {
            let results = db!.executeQuery("SELECT ID FROM ITEMS WHERE ROWID = last_insert_rowid()", withParameterDictionary: nil)
            if let results = results {
                results.next()
                return results.int(forColumn: "ID")
            }
        }
        return nil
    }
    
    func removeItem(id: Int32) -> Bool {
        return db!.executeUpdate("DELETE FROM ITEMS WHERE ID = \(id)", withParameterDictionary: [:])
    }
}
