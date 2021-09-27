//
//  EventBroadcaster.swift
//
//  Created by Ali Samaiee on 9/21/21.
//

import Foundation

/// A custom lightweight event handler
public class EventBroadcaster {
    public static let sharedInstance = EventBroadcaster()
    
    private var observers = [Int: [Weak<AnyObject>]]()
    private var removeAfterBroadcast = [Int: [Weak<AnyObject>]]()
    private var addAfterBroadcast = [Int: [Weak<AnyObject>]]()
    private var delayedPosts = Array<DelayedPost?>(repeating: nil, count: 10)
    
    private var broadcasting = 0
    private var animationInProgress: Bool = false
    
    private var allowedNotifications: [Int]?
    
    public func setAnimationInProgress(value: Bool) {
        self.animationInProgress = value
        if (!animationInProgress && !self.delayedPosts.isEmpty) {
            for delayedPost in self.delayedPosts {
                if let strongPost = delayedPost {
                    do {
                        try self.broadcastEventInternal(strongPost.id, true, strongPost.args)
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
            delayedPosts.removeAll()
        }
    }
    
    public func broadcastEvent(_ id: Int, _ args: [Any], forceDuringAnimations: Bool = false) {
        var allowDuringAnimation = forceDuringAnimations
        if self.allowedNotifications != nil && !forceDuringAnimations {
            for allowedNotification in self.allowedNotifications! {
                if allowedNotification == id {
                    allowDuringAnimation = true
                    break
                }
            }
        }
        try? self.broadcastEventInternal(id, allowDuringAnimation, args)
    }
    
    private func broadcastEventInternal(_ id: Int, _ allowDuringAnimation: Bool, _ args: [Any]) throws {
        if !Thread.isMainThread {
            throw RuntimeError("EventBroadcaster::postNotificationNameInternal -> allowed only from MAIN thread")
        }
        
        if !allowDuringAnimation && animationInProgress {
            let delayedPost = DelayedPost(id,args)
            self.delayedPosts.append(delayedPost)
            
            return
        }
        
        self.broadcasting += 1
        self.observers[id]?.reap()
        let objects = self.observers[id]

        if objects != nil && !objects!.isEmpty {
            for obj in objects! {
                if let delegate = obj as? EventBroadcasterDelegate {
                    delegate.didReceivedNotification(id, args: args)
                }
            }
        }
        self.broadcasting -= 1
        if self.broadcasting == 0 {
            if !removeAfterBroadcast.isEmpty {
                for object in removeAfterBroadcast {
                    let arrayList = object.value
                    
                    for obj in arrayList {
                        try self.removeObserver(obj, object.key)
                    }
                }
                removeAfterBroadcast.removeAll()
            }
            if !addAfterBroadcast.isEmpty {
                for object in addAfterBroadcast {
                    let key = object.key
                    let value = object.value
                    
                    for obj in value {
                        guard let castedObj = obj as? EventBroadcasterDelegate else {
                            fatalError("EventBroadcaster:: [ERROR] postNotificationNameInternal: Unexpected observer type")
                        }
                        try self.addObserver(castedObj, key)
                    }
                }
                addAfterBroadcast.removeAll()
            }
        }
    }
    
    /// Don't forget to call removeObserver when your observing task is over
    public func addObserver(_ observer: AnyObject & EventBroadcasterDelegate, _ id: Int) throws {
        if !Thread.isMainThread {
            throw RuntimeError("EventBroadcaster::postNotificationNameInternal -> allowed only from MAIN thread")
        }
        
        var objects = self.observers[id]
        if objects == nil {
            objects = [Weak<AnyObject>]()
        }
        
        if objects!.contains(where: { anyObjectListItem -> Bool in return observer === anyObjectListItem }) {
            return
        }
        
        let weakObserver = Weak<AnyObject>(value: observer)
        objects!.append(weakObserver)
        
        self.observers[id] = objects!
    }
    
    public func removeObserver(_ observer: AnyObject, _ id: Int) throws {
        if !Thread.isMainThread {
            throw RuntimeError("EventBroadcaster::postNotificationNameInternal -> allowed only from MAIN thread")
        }
        
        if broadcasting != 0 {
            var arrayList = removeAfterBroadcast[id]
            if arrayList == nil {
                arrayList = [Weak<AnyObject>]()
                removeAfterBroadcast[id] = arrayList
            }
            let weakObserver = Weak(value: observer)
            arrayList?.append(weakObserver)
            return
        }
        var objects = observers[id]
        if objects != nil {
            let index = objects?.firstIndex(where: { anyObjectListItem -> Bool in
                return anyObjectListItem === observer
            })
            
            if index != nil {
                objects?.remove(at: index!)
                self.observers[id] = objects!
            }
        }
    }
    
    public func cleanup() {
        self.observers.removeAll()
        self.removeAfterBroadcast.removeAll()
        self.addAfterBroadcast.removeAll()
        self.delayedPosts.removeAll()
        self.allowedNotifications?.removeAll()
    }
}

public protocol EventBroadcasterDelegate: class {
    func didReceivedNotification(_ id: Int, args: [Any])
}

internal class DelayedPost {
    fileprivate let id: Int!
    fileprivate let args: [Any]
    
    fileprivate init(_ id: Int, _ args: [Any]) {
        self.id = id
        self.args = args
    }
}
