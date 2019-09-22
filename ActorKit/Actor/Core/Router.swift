//
//  Router.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

/// For each message that is sent through the router via the #route
/// method the RoutingLogic decides to which Routee to send the message.
/// The Routee itself knows how to perform the actual sending.
/// Normally the RoutingLogic picks one of the contained routees,
/// but that is up to the implementation of the RoutingLogic.
class Router {
    var routees: [Routee]
    let routingLogic: RoutingLogic
    let sender: ActorRef?
    
    /// Сreate an instance of a router in which we put the Routees, which in essence are message listeners.
    /// Messages are sent in accordance with the provided logic, use Strategy pattern.
    ///
    /// - Parameter routees: List of Routee. Routee - abstraction of a destination for messages routed via a Router
    /// - Parameter logic: The logic by which messages will be sent. For example Broadcasting or Iterative
    /// - Parameter sender: The owner on whose behalf messages will be sent
    /// - Returns: ActorRef - Immutable handle to an actor
    init(routees: [Routee], logic: RoutingLogic, sender: ActorRef? = nil) {
        self.routees = routees
        self.routingLogic = logic
        self.sender = sender
    }
    
    /// Send the message to the destination Routee selected by the RoutingLogic.
    ///
    /// - Parameter msg: any message
    func route(msg: AKMessage) {
        routingLogic.route(routees, msg: msg, sender: sender)
    }
}

/// RoutingLogic protocol (strategy pattern)
protocol RoutingLogic {
    
    /// Sending messages
    ///
    /// - Parameter routees: List of Routee. Routee - abstraction of a destination for messages routed via a Router
    /// - Parameter msg: any message
    /// - Parameter sender: The owner on whose behalf messages will be sent
    func route(_ routees: [Routee], msg: AKMessage, sender: ActorRef?)
}

/// Iteratively sends a message
class IterativelyRoutingLogic: RoutingLogic {
    private var index = 0
    
    /// Sending messages with Iterative logic
    ///
    /// - Parameter routees: List of Routee. Routee - abstraction of a destination for messages routed via a Router
    /// - Parameter msg: any message
    /// - Parameter sender: The owner on whose behalf messages will be sent
    func route(_ routees: [Routee], msg: AKMessage, sender: ActorRef?) {
        defer {
            index += 1
            if index >= routees.count { index = 0 }
        }
        let routee = index < routees.count ? routees[index] : nil
        routee?.send(msg, sender: sender)
    }
}

/// Broadcast sends a message
class BroadcastRoutingLogic: RoutingLogic {
    
    /// Sending messages with Broadcast logic
    ///
    /// - Parameter routees: List of Routee. Routee - abstraction of a destination for messages routed via a Router
    /// - Parameter msg: any message
    /// - Parameter sender: The owner on whose behalf messages will be sent
    func route(_ routees: [Routee], msg: AKMessage, sender: ActorRef?) {
        routees.forEach { $0.send(msg, sender: sender) }
    }
}

/// Abstraction of a destination for messages routed via a Router
class Routee {
    let actorRef: ActorRef
    
    /// Сreate an instance of a abstraction of a destination for messages routed via a Router
    ///
    /// - Parameter actorRef: Immutable handle to an actor
    init(actorRef: ActorRef) {
        self.actorRef = actorRef
    }
    
    /// Send message
    ///
    /// - Parameter msg: any message
    /// - Parameter sender: The owner on whose behalf messages will be sent
    fileprivate func send(_ msg: AKMessage, sender: ActorRef?) {
        actorRef.tell(msg, sender: sender)
    }
}



