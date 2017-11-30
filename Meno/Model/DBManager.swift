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
    
    func open(filePath: URL, completed: (Bool) -> Void) {
        db = FMDatabase(url: filePath)
        
        let result = db!.open()
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
    
    func getNote(id: Int) -> String {
        let results = db?.executeQuery("SELECT TEXT FROM ITEMS WHERE ID=\(id)", withParameterDictionary: nil)
        
        if let results = results {
            results.next()
            return results.string(forColumn: "TEXT") ?? ""
        }
        
        return ""
    }
    
    @discardableResult
    func saveNote(id: Int, content: String) -> Bool {
        return db!.executeUpdate("UPDATE ITEMS SET TEXT=\"\(content)\" WHERE ID=\(id)", withParameterDictionary: [:])
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
