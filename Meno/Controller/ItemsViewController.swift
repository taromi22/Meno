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
    @IBOutlet var arrayController: NSArrayController!
    
    weak var delegate: ItemsViewControllerDelegate?
    
    var preSelectedId = -1
    @objc var items = [NoteProfile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
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
        if self.arrayController.selectionIndexes.count == 1 {
            return (self.arrayController.selectedObjects[0] as! NoteProfile).id
        } else {
            return nil
        }
    }
    
    func addItem(_ item: NoteProfile) {
        NSAnimationContext.runAnimationGroup({ (context) in
            self.tableView.insertRows(at: IndexSet(integer: 0), withAnimation: .slideDown)
        }) {
            self.arrayController.insert(item, atArrangedObjectIndex: 0)
        }
        
        let newid = item.id
        delegate?.itemsViewControllerSelectionChanged(id: newid)
    }
    
    func removeSelectedItem() {
        let selection = self.arrayController.selectionIndexes
        NSAnimationContext.runAnimationGroup({
            (context) in
            self.tableView.removeRows(at: selection, withAnimation: .effectFade)
        }) {
            self.arrayController.remove(atArrangedObjectIndexes: selection)
        }
    }
    
    func setItems(_ items: [NoteProfile]) {
        self.arrayController.add(contentsOf: items)
        
        self.arrayController.setSelectionIndex(0)
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
