//
//  DateTransformerForTableView.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/03.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class DateTransformerForTableView: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    override func transformedValue(_ value: Any?) -> Any? {
        if let date = value as? Date {
            let interval = Int(-date.timeIntervalSinceNow)
            let dayInterval = interval/60/60/24
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            
            switch dayInterval {
            case 0:
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return "今日 " + formatter.string(from: date)
            case 1...7 :
                return String(dayInterval) + "日前"
            default:
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                return formatter.string(from: date)
            }
        } else {
            return nil
        }
    }
}

extension NSValueTransformerName {
    static let dateTransformerForTableView = NSValueTransformerName("DateTransformerForTableView")
}
