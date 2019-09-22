//
//  Document.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 18/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

// Структура документа
struct Document: AKMessage {
    let sender: String
    let text: String
}
