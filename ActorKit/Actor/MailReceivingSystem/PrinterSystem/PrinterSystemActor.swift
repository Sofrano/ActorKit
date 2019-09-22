//
//  PrinterSystemActor.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

/*
    Система управления распределенными принтерами. Система знает обо всех подключенных к нему принтерах
    И на каждый из них создается PrinterActor по работе с конкретным принтером.
    Также имеется внутренний счетчик уже РАСПЕЧАТАННЫХ документов (не отправленных на печать,
    а именно распечатанных. Все принтеры зарегистрированы в так называем роутере, который в
    зависимости от своих настроек по определенной логике пересылает сообщения принтерам.
*/
class PrinterSystemActor: Actor, ActorInputtable {
    typealias InputMessages = PrinterSystemInputMessages
    
    private var router: Router?
    private var counterActorRef: ActorRef?
    private var counter: Int = 0
    
    // Логика актора по получению сообщения из MailBox'a
    override func onReceive(_ msg: AKMessage) {
        switch msg {
        case let msg as PrinterSystemInputMessages:
            handleMessage(msg)
        case let msg as MailServiceOutputMessages:
            handleMessage(msg)
        case let msg as PrinterActorOutputMessages:
            handleMessage(msg)
        default:
            unhandled(msg)
        }
    }
    
}

extension PrinterSystemActor: MailServiceMessageOutputHandler, PrinterActorMessageOutputHandler {
    
    func handleDocument(_ document: Document) {
        router?.route(msg: PrinterSystemOutputMessages.print(document: document))
    }
    
    func printed(_ document: Document) {
        counter += 1
        counterActorRef?.tell(StatisticsMessages.updatePrintedCounter(count: counter))
    }
    
}

extension PrinterSystemActor: PrinterSystemMessageInputHandler {
    func registerCounter(_ actor: ActorRef) {
        counterActorRef = actor
    }
    
    func configuration(printersCount: Int) {
        router = Router(routees: [],
                        logic: IterativelyRoutingLogic(),
                        sender: getActorRef())
        for number in 1...printersCount {
            let actorRef = context.actorOf(PrinterActor.props(id: number),
                                           name: "printer-\(number)")
            router?.routees.append(Routee(actorRef: actorRef))
        }
    }
}

///////////////////////// Input /////////////////////////

enum PrinterSystemInputMessages: AKMessage {
    case registerCounter(actor: ActorRef)
    case configuration(printersCount: Int)
}

private protocol PrinterSystemMessageInputHandler: AKMessageHandler {
    func registerCounter(_ actor: ActorRef)
    func configuration(printersCount: Int)
}

private extension PrinterSystemMessageInputHandler {
    func handleMessage(_ message: PrinterSystemInputMessages) {
        switch message {
        case .registerCounter(let actor):
            registerCounter(actor)
        case .configuration(let printersCount):
            configuration(printersCount: printersCount)
        }
    }
}

///////////////////////// Output /////////////////////////

enum PrinterSystemOutputMessages: AKMessage {
    case print(document: Document)
}

protocol PrinterSystemMessageOutputHandler: AKMessageHandler {
    func printing(_ document: Document)
}

extension PrinterSystemMessageOutputHandler {
    func handleMessage(_ message: PrinterSystemOutputMessages) {
        switch message {
        case .print(let document):
            printing(document)
        }
    }
}
