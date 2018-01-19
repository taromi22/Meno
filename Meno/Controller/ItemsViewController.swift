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
    var transitionManager: NoteTransitionManager!
    @objc var items = [NoteProfile]()
    var preSelectedItem: NoteProfile?
    
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
    
    // 選択が変わったとき，現在のノートを保存して新しいノートを読み込む
    // ユーザーが選択したかどうかを区別するため，クリックアクションで拾っている
    @IBAction func Clicked(_ sender: Any) {
        guard let newProfile = self.selectedProfile else {
            return
        }
        
        if newProfile != self.preSelectedItem {
            self.editViewController.saveAndLoad(newProfile: newProfile)
            self.preSelectedItem = self.selectedProfile
            self.transitionManager.clear()
            self.editViewController.contentView.isBackButtonHidden = true
        }
    }

    // 新たなノートを追加する．
    func addItem(_ item: NoteProfile) {
        self.arrayController.insert(item, atArrangedObjectIndex: 0)
        
        self.editViewController.saveAndLoad(newProfile: item)
    }
    // 選択したノートを削除する．
    func removeSelectedItem() {
        let selectedIndexes = self.arrayController.selectionIndexes
        
        // 削除のアニメーション．アニメーション終了と同時にArrayControllerに削除の指示をする
        NSAnimationContext.runAnimationGroup({
            (context) in
            self.tableView.removeRows(at: selectedIndexes, withAnimation: .effectFade)
        }) {
            self.arrayController.remove(atArrangedObjectIndexes: selectedIndexes)
        }
        
        if let profile = self.selectedProfile {
            self.editViewController.saveAndLoad(newProfile: profile)
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
        self.editViewController.saveAndLoad(newProfile: self.selectedProfile!)
        
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
                self.editViewController.saveAndLoad(newProfile: profile)
            }
            count += 1
        }
    }
}
