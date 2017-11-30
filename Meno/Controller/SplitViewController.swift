//
//  SplitViewController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/14.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
    
    var titlesViewController: ItemsViewController? {
        return splitViewItems[0].viewController as? ItemsViewController
    }
    var editViewController: EditViewController? {
        return splitViewItems[1].viewController as? EditViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        self.splitView.setPosition(CGFloat(300), ofDividerAt: 0)
    }
    
    
}
