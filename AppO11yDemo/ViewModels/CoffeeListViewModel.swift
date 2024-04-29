//
//  CoffeeListViewModel.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation
import Combine

@MainActor
class CoffeeListViewModel: ObservableObject {
    @Published var coffees: [Coffee] = []
    @Published var isLoading = false
    @Published var error: ApiError? = nil
    
    private let coffeeService: CoffeeServiceProtocol
    private var disposeBag: Set<AnyCancellable> = []

    init(coffeeService: CoffeeServiceProtocol = InjectedValues[\.coffeeService]) {
        self.coffeeService = coffeeService

        coffeeService.coffeesPublisher.sink { [weak self] nextCoffees in
            self?.coffees = nextCoffees
        }.store(in: &disposeBag)

        coffeeService.isLoadingPublisher.assign(to: &$isLoading)
        coffeeService.errorPublisher.assign(to: &$error)
    }
    
    func getCoffees() async {
        coffeeService.getCoffees()
    }
    
    func getErrorText(_ error: ApiError) -> String {
        return "Failed to load coffees with error:\n\(error)"
    }
}
