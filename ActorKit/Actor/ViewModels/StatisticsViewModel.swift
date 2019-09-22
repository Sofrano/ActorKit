//
//  StatisticsViewModel.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 17/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct StatisticsфViewModel {
    let input = Input()
    let output: Output
    
    struct Input {
        let totalPrinted = PublishSubject<Int>()
        let totalSaved = PublishSubject<Int>()
    }
    
    struct Output {
        let totalPrinted: Driver<String>
        let totalSaved: Driver<String>
    }
    
    init() {
        let totalPrinted = input.totalPrinted
            .asObservable().map { "Кол-во распечатанных: \($0)" }
            .asDriver(onErrorJustReturn: "")
        let totalSaved = input.totalSaved
            .asObservable().map { "Кол-во сохраненных в БД: \($0)" }
            .asDriver(onErrorJustReturn: "")
        output = Output(totalPrinted: totalPrinted,
                        totalSaved: totalSaved)
    }
}
