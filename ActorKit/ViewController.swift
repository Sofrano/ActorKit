//
//  ViewController.swift
//  ActorKit
//
//  Created by Dmitriy Safarov on 16/09/2019.
//  Copyright © 2019 SimpleCode. All rights reserved.
//

import UIKit
import Starscream
import RxSwift
import RxCocoa

// ViewController на котором лежит вся логика по работе с Акторами.
// Сделан на скорую руку, просьба не учитывать все подходы для реализации
// примера работы с актором (в частности архитектурный подход, работа с вью моделью и тд)
class ViewController: UIViewController {

    private let actorSystem = ActorSystem()
    private let disposeBag = DisposeBag()
    
    let port = 8020
    let printersCount = 100
    let documentsCount = 10000
    
    lazy var countPrintedLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 300, height: 30))
        view.addSubview(label)
        return label
    }()
    
    lazy var countDBSavedLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: 130, width: 300, height: 30))
        view.addSubview(label)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Создаем актор по работе с принтерами, который умеет автоматически
        // распечатывать поступившую информацию. Также считает кол-во РАСПЕЧАТАННЫХ
        // документов
        let printerSystemActor = actorSystem.actorOf(PrinterSystemActor.emptyProps(),
                                                     name: "printer actor")
        // Конфигурируем
        printerSystemActor ! PrinterSystemActor.InputMessages.configuration(printersCount: 200)
        
        // Создаем актор по псевдо работе с БД.
        let dbActor = actorSystem.actorOf(DBActor.emptyProps(),
                                          name: "db")
        
        // ********** Start UI Actor ******** /
        
        // Создаем UI актор, который позже передадим для прослушки количества распечатанных
        // документов и количества записанных в базу документов
        let viewModel = createViewModel()
        let statisticsActorUI = actorSystem.actorOf(StatisticsActorUI.props(viewModel: viewModel), name: "viewmodel")
        // Регистрируем statisticsActorUI на фиксацию изменений статистики принтера
        printerSystemActor ! PrinterSystemActor.InputMessages.registerCounter(actor: statisticsActorUI)
        // Регистрируем statisticsActorUI на фиксацию изменений статистики количества записанных в базу документов
        dbActor !  DBActorMessages.registerCounter(actor: statisticsActorUI)
        // ********** End UI Actor ******** /
        
        
        // Создаем основной актор - система по получению почтовых документов
        let props = MailServiceActor.props(port: 8080,
                                            broadcastRouteActors: [printerSystemActor, dbActor],
                                            documentsCount: documentsCount)
        let mailRecieverActor = actorSystem.actorOf(props,
                                                    name: "mailReciever")
        // Высылаю новую конфигурацию, с другим портом
        mailRecieverActor ! MailServiceActor.InputMessages.configuration(port: 8020)
    }

    func createViewModel() -> StatisticsViewModel {
        let viewModel = StatisticsViewModel()
        
        viewModel.output.totalPrinted.drive(onNext: { [unowned self] (value) in
            self.countPrintedLabel.text = value
        }).disposed(by: disposeBag)
        
        viewModel.output.totalSaved.drive(onNext: { [unowned self] (value) in
            self.countDBSavedLabel.text = value
        }).disposed(by: disposeBag)
        
        return viewModel
    }
    
}

