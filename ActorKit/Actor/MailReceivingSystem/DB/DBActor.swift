//
//  DBActor.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

// Фейковый актор по работе с БД, все работает в асинхронном режиме
class DBActor: Actor {
    private var totalSaves: Int = 0
    private var counter: ActorRef?
    
    // Получаем и обрабатываем сообщение
    override func onReceive(_ msg: AKMessage) {
        switch msg {
        case let message as MailServiceOutputMessages:
            handleMessage(message)
        case let message as DBActorMessages:
            switch message {
            case .registerCounter(let actor):
                counter = actor
            }
        default:
            unhandled(msg)
        }
        
    }
    
}

extension DBActor: MailServiceMessageOutputHandler {
    // Фиксируем запись в базу данных
    func handleDocument(_ document: Document) {
        totalSaves += 1
        counter?.tell(StatisticsMessages.updateDBCounter(count: totalSaves))
    }
    
}

enum DBActorMessages: AKMessage {
    case registerCounter(actor: ActorRef)
}
