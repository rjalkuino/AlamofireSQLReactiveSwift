//
//  Utils.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

func uuid() -> UUID {
    return UUID()
}

func isValidEmail(email: String) -> Bool {
    let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}

func isValidPassword(password: String) -> Bool {
    return password.count >= 5
}

func isValidUserName(userName: String) -> Bool {
    let userNameRegEx = "^[a-zA-Z0-9_]+$"
    let userNameTest = NSPredicate(format:"SELF MATCHES %@", userNameRegEx)
    return userNameTest.evaluate(with: userName)
}

func identity<T>(el: T) -> T {
    return el
}

func calcTextHeight(text: String, withWidth width: CGFloat, andFont font: UIFont) -> CGFloat {
    if text.isEmpty {
        return 0
    }
    
    let attributes = [NSAttributedString.Key.font: font]
    let textAS = NSAttributedString(string: text, attributes: attributes)
    let tmpSize = CGSize(width: width, height: 100000)
    let textRect = textAS.boundingRect(with: tmpSize, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return textRect.height
}

func calcTextWidth(text: String, withFont font: UIFont) -> CGFloat {
    if text.isEmpty {
        return 0
    }
    
    let size = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    return size.width
}

class NotificationSignal<T> {
    
    let (signal, sink) = Signal<T, Never>.pipe()
    
    func notify(value: T) {
        sink.send(value: value)
    }
    
    func dispose() {
        sink.sendInterrupted()
    }
    
}

func isTrue(val: Bool) -> Bool {
    return val
}

func isFalse(val: Bool) -> Bool {
    return !val
}

func negate(val: Bool) -> Bool {
    return !val
}

func isEmpty(val: String) -> Bool {
    return val.isEmpty
}

func isNotEmpty(val: String) -> Bool {
    return !val.isEmpty
}

func and(a: Bool, _ b: Bool) -> Bool {
    return a && b
}

func or(a: Bool, _ b: Bool) -> Bool {
    return a || b
}

//todo
//func toDictionary<E, K, V>(array: [E], transformer: (_ element: E) -> (key: K, value: V)?) -> Dictionary<K, V> {
//    var dict:Dictionary = [:]
//    return array.reduce([:]) { ( d, e) in
//        if var (key, value) = transformer(e) {
//            dict[key] = value
//        }
//        return dict
//    }
//}

func safeOptional<T>(val: T!) -> T? {
    if let val = val {
        return val
    } else {
        return nil
    }
}

func sync(obj: AnyObject, fn: () -> ()) {
    objc_sync_enter(obj)
    fn()
    objc_sync_exit(obj)
}

