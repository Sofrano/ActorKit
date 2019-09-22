//
//  PrinterActor.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

/*
 Actor принтера. Случайным образом генерируется скорость печати этого принтера.
 Данный актор, уведомляет о том что печать документа окончена, и берет следующий документ
 с очереди в MailBox'e
*/
class PrinterActor: Actor {
    private var id: Int = 0
    lazy var uniqueSleep: UInt32 = {
        return UInt32.random(in: 500000...2000000)
    }()
    
    // Передача параметров инициализации
    static func props(id: Int) -> Props {
        let props = Props(PrinterActor.self, onConfigure: { (actor) in
            guard let actor = actor as? PrinterActor else { return }
            actor.id = id
        })
        return props
    }
    
    // Получаем и обрабатываем сообщение
    override func onReceive(_ msg: AKMessage) {
        switch msg {
        case let message as PrinterSystemOutputMessages:
            handleMessage(message)
        default:
            unhandled(msg)
        }
    }
    
}

extension PrinterActor: PrinterSystemMessageOutputHandler {
    
    func printing(_ document: Document) {
        print("Printing on printer id-\(id): \(document.sender)")
        usleep(uniqueSleep)
        sender?.tell(PrinterActorOutputMessages.done(document: document), sender: self.getActorRef())
    }
    
}

//////////////////// OUTPUT ////////////////////

enum PrinterActorOutputMessages: AKMessage {
    case done(document: Document)
}

protocol PrinterActorMessageOutputHandler: AKMessageHandler {
    func printed(_ document: Document)
}

extension PrinterActorMessageOutputHandler {
    func handleMessage(_ message: PrinterActorOutputMessages) {
        switch message {
        case .done(let document):
            printed(document)
        }
    }
}

