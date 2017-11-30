//
//  ItemsViewController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/14.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class ItemsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    weak var delegate: ItemsViewControllerDelegate?
    
    var preSelectedId = -1
    var items = [NoteProfile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row < items.count {
            let note = items[row]
            if tableColumn!.identifier.rawValue == "Title" {
                return note.title != "" ? note.title : "タイトルなし"
            }
        }
        return ""
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        let id = selectedId()
        delegate?.itemsViewControllerSelectionChanging(id: id)
        
        return proposedSelectionIndexes
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let id = selectedId()
        delegate?.itemsViewControllerSelectionChanged(id: id)
    }
    
    func selectedId() -> Int? {
        let row = self.tableView.selectedRow
        if row >= 0 && row < self.items.count {
            return self.items[row].id
        }
        
        return nil
    }
    
    func update() {
        self.tableView.reloadData()
    }
    
    func addItem(_ item: NoteProfile) {
        self.items.insert(item, at: 0)
        
        self.update()
        
        self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        
        let newid = self.items[0].id
        delegate?.itemsViewControllerSelectionChanged(id: newid)
    }
    
    func removeSelectedItem() {
        let row = self.tableView.selectedRow
        if row >= 0 && row < self.items.count {
            self.items.remove(at: row)
            
            self.update()
            
            var newid: Int?
            
            if row < self.items.count {
                self.tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                newid = self.items[row].id
            } else {
                self.tableView.selectRowIndexes(IndexSet(integer: self.items.count-1), byExtendingSelection: false)
                newid = self.items[self.items.count-1].id
            }
            
            delegate?.itemsViewControllerSelectionChanged(id: newid!)
        }
    }
    
    func setItems(_ items: [NoteProfile]) {
        self.items = items
        
        self.update()
        
        if self.items.count > 0 {
            self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
}

protocol ItemsViewControllerDelegate: class {
    func itemsViewControllerSelectionChanged(id: Int?)
    func itemsViewControllerSelectionChanging(id: Int?)
}
extension ItemsViewControllerDelegate {
    func itemsViewControllerSelectionChanged(id: Int?) { }
    func itemsViewControllerSelectionChanging(id: Int?) { }
}
