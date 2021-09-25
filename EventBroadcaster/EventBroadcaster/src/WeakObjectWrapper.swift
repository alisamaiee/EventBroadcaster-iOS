//
//  WeakObjectWrapper.swift
//
//  Created by Ali Samaiee on 9/23/21.
//

import Foundation

internal class Weak<T: AnyObject> {
    weak var value: T?
    init (value: T) {
        self.value = value
    }
}

internal extension Array where Element: Weak<AnyObject> {
    mutating func reap () {
        self = self.filter { nil != $0.value }
    }
}
