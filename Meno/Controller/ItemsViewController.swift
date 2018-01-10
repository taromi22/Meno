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
    
    var editViewController: EditViewController!
    var preSelectedProfile: NoteProfile? = nil
    @objc var items = [NoteProfile]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerForDraggedTypes([NoteProfile.pasteboardTypeNoteProfile])
        tableView.setDraggingSourceOperationMask([.link], forLocal: true)
        
        let sortDescriptor = NSSortDescriptor(key: "self.updatedDate", ascending: false)
        arrayController.sortDescriptors = [sortDescriptor]
    }
    
    override var representedObject: Any? {
        didSet {
            // 今後ここに保存・ロード処理を入れることでバインディングを活用する？
        }
    }
    
    // TableViewは編集禁止
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let list = self.arrayController.arrangedObjects as! [NoteProfile]
        var selected = [NoteProfile]()
        
        for i in rowIndexes {
            selected.append(list[i])
        }
        pboard.clearContents()
        pboard.writeObjects(selected)
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        
        return proposedSelectionIndexes
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let newProfile = self.selectedProfile {
        
            self.editViewController.saveAndLoad(newProfile: newProfile)
            self.preSelectedProfile = newProfile
        }
    }
    
    // 新たなノートを追加する．
    func addItem(_ item: NoteProfile) {
        self.preSelectedProfile = selectedProfile
        
        self.arrayController.insert(item, atArrangedObjectIndex: 0)

        self.preSelectedProfile = selectedProfile
    }
    // 選択したノートを削除する．
    func removeSelectedItem() {
        // ArrayControllerのselectionIndexesとselectedObjectsを両方使うことにする．両者が常に一致しているという前提
        let selectedIndexes = self.arrayController.selectionIndexes
        let profiles = self.selectedProfiles
        
        // preSelectedProfileを破棄する．無駄な更新をしないように．
        if self.preSelectedProfile != nil && profiles?.contains(preSelectedProfile!) ?? false {
            self.preSelectedProfile = nil
        }
        
        // 削除のアニメーション．アニメーション終了と同時にArrayControllerに削除の指示をする
        NSAnimationContext.runAnimationGroup({
            (context) in
            self.tableView.removeRows(at: selectedIndexes, withAnimation: .effectFade)
        }) {
            self.arrayController.remove(atArrangedObjectIndexes: selectedIndexes)
        }
        
    }
    
    // ノートのリストを読み込む
    func setItems(_ items: [NoteProfile], didSet: ()->()) {
        // すべてのアイテムを削除
        if let items = self.arrayController.arrangedObjects as? [Any],
            items.count > 0 {
            
            self.arrayController.remove(atArrangedObjectIndexes: IndexSet(integersIn: 0..<items.count))
        }
        self.arrayController.add(contentsOf: items)
        // 日付順に並び替え
        self.arrayController.rearrangeObjects()
        // 一番上を選択
        self.arrayController.setSelectionIndex(0)
        
        didSet()
    }
    // 選択中のノートの日時を更新したときに呼ぶ．
    func raiseSelectedItem() {
        if self.arrayController.selectionIndex == 0 {
            return
        }
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.allowsImplicitAnimation = true
            context.duration = 0.5
            
            self.tableView.moveRow(at: self.tableView.selectedRow, to: 0)
            
            self.tableView.scrollRowToVisible(0)
        }) {
            self.arrayController.rearrangeObjects()
        }
    }
    
    /// 指定したidのノートを選択する．
    func select(id: Int32) {
        let items = arrayController.arrangedObjects as! [NoteProfile]
        var count = 0
        for profile in items {
            if profile.id == id {
                self.tableView.selectRowIndexes(IndexSet(integer: count), byExtendingSelection: false)
            }
            count += 1
        }
    }
}
