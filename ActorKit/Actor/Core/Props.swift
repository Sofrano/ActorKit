//
//  Props.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

/// Props is a Actor configuration object, that is immutable,
/// so it is thread safe and fully sharable.
class Props {
    let actorType: Actor.Type
    let onConfigure: ((Actor) -> Void)?
    
    /// Creates a props instance. Props is a Actor configuration object, that is immutable
    ///
    /// - Parameter actorType: Any type inherited from an actor
    /// - Parameter onConfigure: the callback that will be called by the actor system,
    /// and an initialized instance of the actor will be transferred. Used to configure the actor.
    init(_ actorType: Actor.Type, onConfigure: ((Actor) -> Void)? = nil) {
        self.actorType = actorType
        self.onConfigure = onConfigure
    }
    
}
