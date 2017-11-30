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
    
    func getProfiles() -> [NoteProfile] {
        let results = db?.executeQuery("SELECT ID, TITLE FROM ITEMS", withParameterDictionary: nil)
        var profiles: [NoteProfile] = []
        
        if let results = results {
            while results.next() {
                let title = results.string(forColumn: "title") ?? ""
                let id = Int(results.int(forColumn: "id"))
                
                profiles.append(NoteProfile(id: id, title: title, text: "", date: NSDate()))
            }
        }
        
        return profiles
    }
    
    func getNote(id: Int) -> Data? {
        let results = db?.executeQuery("SELECT TEXT FROM ITEMS WHERE ID=\(id)", withParameterDictionary: nil)
        
        if let results = results {
            results.next()
            return results.data(forColumn: "TEXT")
        }
        
        return nil
    }
    
    @discardableResult
    func saveNote(id: Int, content: Data) -> Bool {
        return db!.executeUpdate("UPDATE ITEMS SET TEXT=? WHERE ID=\(id)", withArgumentsIn: [content])
    }
    
    func addNew() -> Int? {
        if db!.executeUpdate("INSERT INTO ITEMS DEFAULT VALUES", withParameterDictionary: [:]) {
            let results = db!.executeQuery("SELECT ID FROM ITEMS WHERE ROWID = last_insert_rowid()", withParameterDictionary: nil)
            if let results = results {
                results.next()
                return Int(results.int(forColumn: "ID"))
            }
        }
        return nil
    }
    
    func removeItem(id: Int) -> Bool {
        return db!.executeUpdate("DELETE FROM ITEMS WHERE ID = \(id)", withParameterDictionary: [:])
    }
}
