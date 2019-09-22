//
//  Actor.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation


public protocol ActorInputtable {
    associatedtype InputMessages
}

/// Universal primitive of parallel execution.
/// The actor model in computer science is a mathematical model of concurrent
/// computation that treats "actors" as the universal primitives of concurrent
/// computation. In response to a message that it receives, an actor can:
/// make local decisions, create more actors, send more messages, and determine how to
/// respond to the next message received. Actors may modify their own private state,
/// but can only affect each other indirectly through messaging
/// (obviating lock-based synchronization).
public class Actor {
    
    // MARK: - Variables
    
    /// MailBox and threading tool all rolled into one
    internal var dispatchQueue: DispatchQueue?
    
    /// Context that allows you to create new or find existing actors
    public let context: ActorSystem!
    
    /// The actor model assumes that at one point in time we are working with one message. This is it
    private(set) public var message: AKMessage!
    
    /// The actor model assumes that at one point in time we are working with one message.
    /// This is the sender of the message.
    private(set) public var sender: ActorRef?
    
    
    // MARK: - Constructors
    
    /// Creates an actor instance. Invoked in ActorSystem
    ///
    /// - Parameter name: The name of this actor, used to distinguish multiple ones within the same class loader
    /// - Parameter context: Context that allows you to create new or find existing actors
    required init(name: String, context: ActorSystem) {
        dispatchQueue = DispatchQueue(label: name)
        self.context = context
    }
    
    // MARK: - Public Functions
    
    /// This is necessary to send messages with sender information.
    ///
    /// - Returns: ActorRef to which this actor belongs.
    public func getActorRef() -> ActorRef? {
        return context.actorFor(dispatchQueue?.label ?? "unknown name")
    }
    
    /// This function creates empty props
    ///
    /// - Returns: Props is a Actor configuration object
    static func emptyProps() -> Props {
        return Props(self.self, onConfigure: nil)
    }
    
    /// Put a message into an MailBox (Serial DispatchQueue)
    ///
    /// - Parameter msg: any message
    /// - Parameter sender: pass nil if there is nobody to reply to
    ///
    /// When a new message arrives, it lays in the queue for processing in the async thread.
    /// Messages are processed according to the FIFO principle
    func put(_ msg: AKMessage, sender: ActorRef?) {
        if let dispatchQueue = self.dispatchQueue {
            dispatchQueue.async {
                self.sender = sender
                self.message = msg
                self.onReceive(msg)
            }
        } else {
            print("self.dispatchQueue is nil")
        }
    }
    
    /// User overridable callback.
    /// Is called when a actor begins to process the next message
    ///
    /// - Parameter msg: any message
    func onReceive(_ msg: AKMessage) {
        unhandled(msg)
    }
    
    
    /// User overridable callback
    /// Is called when a message isn't handled by the current behavior of the actor
    ///
    /// - Parameter msg: any message
    /// - Parameter sender: pass nil if there is nobody to reply to
    func unhandled(_ msg: Any) {
        print("unhandled message")
    }
    
}

/// Primitive for working with UI. Handles messages in the main thread
public class ActorUI: Actor {
    
    /// Put a message into an MailBox (Serial DispatchQueue)
    ///
    /// - Parameter msg: any message
    /// - Parameter sender: pass nil if there is nobody to reply to
    ///
    /// When a new message arrives, it lays in the queue for processing in the main thread.
    /// Messages are processed according to the FIFO principle
    override func put(_ msg: AKMessage, sender: ActorRef?) {
        guard let dispatchQueue = self.dispatchQueue else {
            print("MailBox broken")
            return
        }
        dispatchQueue.async {
            DispatchQueue.main.async {
                self.onReceive(msg)
            }
        }
    }
}

/// An actor system is a hierarchical group of actors which share common configuration,
/// e.g. dispatchers, deployments, remote capabilities and addresses. It is also the
/// entry point for creating or looking up actors.
public class ActorSystem {
    private var actorRefs: [String: ActorRef] = [:]
    private var semaphore = DispatchSemaphore(value: 1)
    
    /// Create new actor as child of this context with the given name,
    /// which must not be null,
    ///
    /// - Parameter props: Props is a configuration object using in creating an Actor; it is immutable, so it is thread-safe and fully shareable.
    /// - Parameter name: The name of this actor, used to distinguish multiple ones within the same class loader
    /// - Returns: ActorRef - Immutable handle to an actor
    func actorOf(_ props: Props, name: String) -> ActorRef {
        semaphore.wait()
        defer { semaphore.signal() }
        
        guard let actorRef = actorRefs[name] else {
            let actor = props.actorType.init(name: name, context: self)
            props.onConfigure?(actor)
            let actorRef = ActorRef(actor: actor)
            actorRefs[name] = actorRef
            return actorRef
        }
        return actorRef
    }
    
    /// Look-up an actor by applying the given path elements, starting from the current context
    ///
    /// - Parameter name: The name of this actor, used to distinguish multiple ones within the same class loader
    /// - Returns: will return an instance of 'ActorRef' if it exists in the system, otherwise it will return a 'nil'
    func actorFor(_ name: String) -> ActorRef? {
        semaphore.wait()
        defer { semaphore.signal() }
        return actorRefs[name]
    }
    
}

