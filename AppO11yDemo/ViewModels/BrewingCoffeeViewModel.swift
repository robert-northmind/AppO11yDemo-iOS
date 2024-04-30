//
//  BrewingCoffeeViewModel.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 30.04.24.
//

import Combine

@MainActor
class BrewingCoffeeViewModel: ObservableObject {
    @Published var brewingStatusText = ""

    private var coffeeBrewingService: CoffeeBrewingServiceProtocol
    private var disposeBag: Set<AnyCancellable> = []
    private let logger = OTelLogs.instance.getLogger()

    init(coffeeBrewingService: CoffeeBrewingServiceProtocol = InjectedValues[\.coffeeBrewingService]) {
        logger.log("BrewingCoffeeViewModel: got created", severity: .debug)

        self.coffeeBrewingService = coffeeBrewingService

        coffeeBrewingService.brewingStatusPublisher.sink { [weak self] brewingStatus in
            self?.brewingStatusText = brewingStatus.description
        }.store(in: &disposeBag)
    }
    
    func stopBrewing() {
        coffeeBrewingService.cancelBrewing()
    }
}
