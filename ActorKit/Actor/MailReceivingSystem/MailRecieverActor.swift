//
//  MailRecieverActor.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation
import Starscream

/*
 Actor централизованного получения сообщений, к нему могут подключиться другие Actor'ы
 которые будут по своему обрабатывать сообщения. В данном примере к этой системе
 буду подключены сервис отправки на печать с заданным количеством принтеров, а также
 фейковый сервис по записи в БД.
 Для примера, сообщения генерируются самим актором, подключением вебсокета к эхо сервису
*/
class MailServiceActor: Actor, ActorInputtable {
    typealias InputMessages = MailServiceInputMessages
    
    private var broadcastRouter: Router?
    private var socket: WebSocket?
    private var port: Int = 8080
    private var documentsCount: Int = 0
    
    // Начальные настройки актора
    static func props(port: Int = 8080,
                      broadcastRouteActors: [ActorRef] = [],
                      documentsCount: Int) -> Props {
        let props = Props(MailServiceActor.self) { (actor) in
            guard let actor = actor as? MailServiceActor else { return }
            actor.port = port
            actor.documentsCount = documentsCount
            let routees = broadcastRouteActors.map { Routee(actorRef: $0)}
            actor.broadcastRouter = Router(routees: routees,
                                           logic: BroadcastRoutingLogic())
        }
        return props
    }
    
    // Отключение подключения к сокету
    private func disconnect() {
        socket?.disconnect()
    }
    
    // Подключение к сокету
    private func connect() {
        socket = WebSocket(url: URL(string: "wss://echo.websocket.org/")!)
        socket?.delegate = self
        socket?.connect()
    }
    
    // Генерация сообщений, для имитации получения сообщений из вне
    private func generateMessages() {
        DispatchQueue(label: "asdf").async { [unowned self] in
            for number in 1...self.documentsCount {
                self.socket?.write(string: "message \(number)")
            }
        }
    }
    
    // Входная точка получения сообщения Actor'ом от MailBox'a
    override func onReceive(_ msg: AKMessage) {
        switch msg {
        case let message as MailServiceInputMessages:
            handleMessage(message)
        default:
            unhandled(msg)
        }
    }
    
}

// Работа с вебсокетом
extension MailServiceActor: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("connect")
        generateMessages()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("error: \(error.debugDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let sender = ["Dmitriy",
                      "Antonio",
                      "Kenny",
                      "Robin",
                      "Natalya",
                      "Roman"].shuffled().first ?? ""
        let message = Document(sender: sender, text: text)
        handleMessage(message)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}

// Экстеншн с функциями получения сообщений
extension MailServiceActor: MailServiceMessageInputHandler {
    
    // Обработка сообщения о смене конфигурации. В любой момент можно изменить
    // конфигурацию, отправив соответствующую конфигурацию.
    internal func configuration(port: Int) {
        print("watching port: \(port)")
        disconnect()
        connect()
    }
    
    // Обработка сообщения о регистрация нового актора извне,
    // который хочет подключится к системе
    internal func registerChild(_ child: ActorRef) {
        broadcastRouter?.routees.append(Routee(actorRef: child))
    }
    
}

extension MailServiceActor {
    
    // Обработка сообщения о получении почтового письма
    private func handleMessage(_ message: Document) {
        let msg = MailServiceOutputMessages.sendDocument(message)
        broadcastRouter?.route(msg: msg)
    }
    
}

//////////////// Input ///////////////////

public enum MailServiceInputMessages: AKMessage {
    case configuration(port: Int)
    case registerChild(child: ActorRef)
}

private protocol MailServiceMessageInputHandler: AKMessageHandler {
    func configuration(port: Int)
    func registerChild(_ child: ActorRef)
}

private extension MailServiceMessageInputHandler {
    func handleMessage(_ message: MailServiceInputMessages) {
        switch message {
        case .configuration(let port):
            configuration(port: port)
        case .registerChild(let child):
            registerChild(child)
        }
    }
}

//////////////// Output ///////////////////

enum MailServiceOutputMessages: AKMessage {
    case sendDocument(_ document: Document)
}

protocol MailServiceMessageOutputHandler: AKMessageHandler {
    func handleDocument(_ document: Document)
}

extension MailServiceMessageOutputHandler {
    func handleMessage(_ message: MailServiceOutputMessages) {
        switch message {
        case .sendDocument(let document):
            self.handleDocument(document)
        }
    }
}
