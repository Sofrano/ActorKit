//
//  Misc.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 18/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

public protocol AKMessage {}
extension AKMessage {}

protocol AKActorErrorMessage: AKMessage { }
struct ActorError: AKActorErrorMessage {
    enum ErrorType {
        case error(_ text: String)
        case terminated
    }
    let error: ErrorType
}

protocol AKMessageHandler {
    func handleMessage(_ message: AKMessage)
}

extension AKMessageHandler {
    func handleMessage(_ message: AKMessage) {}
}
