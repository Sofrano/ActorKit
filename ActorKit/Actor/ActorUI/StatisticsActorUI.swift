//
//  StatisticsActorUI.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 17/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation

class StatisticsActorUI: ActorUI {
    var viewModel: StatisticsViewModel?
    
    static func props(viewModel: StatisticsViewModel) -> Props {
        let props = Props(StatisticsActorUI.self) { (actor) in
            guard let actor = actor as? StatisticsActorUI else { return }
            actor.viewModel = viewModel
        }
        return props
    }
    
    override func onReceive(_ msg: AKMessage) {
        switch msg {
        case let msg as StatisticsMessages:
            switch msg {
            case .updateDBCounter(let count):
                viewModel?.input.totalSaved.onNext(count)
            case .updatePrintedCounter(let count):
                viewModel?.input.totalPrinted.onNext(count)
            }
        default:
            unhandled(msg)
        }
    }
    
}

enum StatisticsMessages: AKMessage {
    case updatePrintedCounter(count: Int)
    case updateDBCounter(count: Int)
}

