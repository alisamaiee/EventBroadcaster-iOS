//
//  EventBroadcasterError.swift
//
//  Created by Ali Samaiee on 9/21/21.
//

import Foundation

internal struct RuntimeError: Error {
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}
