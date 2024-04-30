//
//  CoffeeDetailViewModel.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation
import Combine

@MainActor
class CoffeeDetailViewModel: ObservableObject {
    @Published var isBrewingCoffee = false

    private var coffeeBrewingService: CoffeeBrewingServiceProtocol
    private var disposeBag: Set<AnyCancellable> = []
    private let logger = OTelLogs.instance.getLogger()

    init(coffeeBrewingService: CoffeeBrewingServiceProtocol = InjectedValues[\.coffeeBrewingService]) {
        logger.log("CoffeeDetailViewModel: got created", severity: .debug)

        self.coffeeBrewingService = coffeeBrewingService
    }
    
    func brewCoffee(_ coffee: Coffee) {
        isBrewingCoffee = true
        Task {
            let didComplete = await coffeeBrewingService.brewCoffee(coffee)
            if didComplete {
                DispatchQueue.main.async {
                    self.isBrewingCoffee = false
                }
            }
        }
    }
}
