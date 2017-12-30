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
    
    var preSelectedProfile: NoteProfile? = nil
    @objc var items = [NoteProfile]()
    
    var maxOrder: Int32? {
        get {
            if let showingItems = self.arrayController.arrangedObjects as? [NoteProfile] {
                return showingItems.last?.order
            }
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        let sortDescriptor = NSSortDescriptor(key: "self.order", ascending: true)
        arrayController.sortDescriptors = [sortDescriptor]
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
        let newProfile = selectedProfile
        delegate?.itemsViewControllerSelectionChanging(newProfile: newProfile, oldProfile: &self.preSelectedProfile)
        
        return proposedSelectionIndexes
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let newProfile = selectedProfile
        delegate?.itemsViewControllerSelectionChanged(newProfile: newProfile, oldProfile: &self.preSelectedProfile)
        self.preSelectedProfile = newProfile
    }
    
    var selectedProfile: NoteProfile? {
        get {
            if self.arrayController.selectionIndexes.count == 1 {
                return self.arrayController.selectedObjects[0] as? NoteProfile
            } else {
                return nil
            }
        }
    }
    
    var selectedProfiles: [NoteProfile]? {
        get {
            if self.arrayController.selectionIndexes.count > 0 {
                return self.arrayController.selectedObjects as? [NoteProfile]
            } else {
                return nil
            }
        }
    }
    
    func addItem(_ item: NoteProfile) {
        self.preSelectedProfile = selectedProfile
        
//        NSAnimationContext.runAnimationGroup({ (context) in
//            self.tableView.insertRows(at: IndexSet(integer: 0), withAnimation: .slideDown)
//        }) {
            self.arrayController.insert(item, atArrangedObjectIndex: self.arrayController.selectionIndex)
            
            self.delegate?.itemsViewControllerSelectionChanged(newProfile: item, oldProfile: &self.preSelectedProfile)
//        }
        
        self.preSelectedProfile = selectedProfile
    }
    
    func removeSelectedItem() {
        // selectionIndexesとselectedProfilesを両方使うことにする．両者が常に一致しているという前提
        let selectedIndexes = self.arrayController.selectionIndexes
        let profiles = self.selectedProfiles
        
        // preSelectedProfileを破棄する．無駄な更新をしないように．
        if self.preSelectedProfile != nil && profiles?.contains(preSelectedProfile!) ?? false {
            self.preSelectedProfile = nil
        }
        
        NSAnimationContext.runAnimationGroup({
            (context) in
            self.tableView.removeRows(at: selectedIndexes, withAnimation: .effectFade)
        }) {
            self.arrayController.remove(atArrangedObjectIndexes: selectedIndexes)
        }
        
    }
    
    func setItems(_ items: [NoteProfile], didSet: ()->()) {
        self.arrayController.add(contentsOf: items)
        self.arrayController.rearrangeObjects()
        self.arrayController.setSelectionIndex(0)
        
        didSet()
    }
}

protocol ItemsViewControllerDelegate: class {
    func itemsViewControllerSelectionChanged(newProfile: NoteProfile?, oldProfile: inout NoteProfile?)
    func itemsViewControllerSelectionChanging(newProfile: NoteProfile?, oldProfile: inout NoteProfile?)
}
extension ItemsViewControllerDelegate {
    func itemsViewControllerSelectionChanged(newProfile: NoteProfile?, oldProfile: inout NoteProfile?) { }
    func itemsViewControllerSelectionChanging(newProfile: NoteProfile?, oldProfile: inout NoteProfile?) { }
}
