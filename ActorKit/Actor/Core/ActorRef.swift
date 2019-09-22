//
//  ActorRef.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

/// Immutable handle to an actor, which may or may not reside on
/// the local host or inside the same ActorSystem. An ActorRef can be obtained
/// from an interface which is implemented by ActorSystem.
open class ActorRef {
    private let actor: Actor
    
    /// ActorRef constructor.
    /// - Parameter actor: instance universal primitive of parallel execution
    init(actor: Actor) {
        self.actor = actor
    }
    
    /// Sends the specified message to this ActorRef, i.e. fire-and-forget
    /// semantics, including the sender reference if possible.
    /// - parameter msg: any message
    /// - parameter sender: pass nil if there is nobody to reply to
    func tell(_ msg: AKMessage, sender: ActorRef? = nil) {
        actor.put(msg, sender: sender)
    }
    
}

/// It makes it possible to send messages using "!"
infix operator  !
public func ! (left:ActorRef, right:AKMessage) -> Void {
    left.tell(right)
}
