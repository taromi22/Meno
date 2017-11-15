//
//  WIndowController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/14.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        if let window = window, let screen = window.screen {
            let screenRect = screen.visibleFrame
            let newOriginY = screenRect.maxY - window.frame.height - LWinY
            window.setFrameOrigin(NSPoint(x: LWinX, y: newOriginY))
            window.setContentSize(LWinSize)
            window.title = LWinTitle
        }
    }

}
