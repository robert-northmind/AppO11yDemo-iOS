//
//  CoffeeService.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation
import Combine

protocol CoffeeServiceProtocol {
    var coffeesPublisher: Published<[Coffee]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<ApiError?>.Publisher { get }

    func getCoffees()
}

class CoffeeService: CoffeeServiceProtocol {
    @Published var coffees: [Coffee] = []
    var coffeesPublisher: Published<[Coffee]>.Publisher { $coffees }
    
    @Published var isLoading = true
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }

    @Published var error: ApiError? = nil
    var errorPublisher: Published<ApiError?>.Publisher { $error }
    
    private let logger = OTelLogs.instance.getLogger()
    
    func getCoffees() {
        error = nil
        isLoading = true

        Task {
            defer {
                DispatchQueue.main.async { self.isLoading = false }
            }
            // Fake slow down the request a bit to be able to see loading indicator
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            guard let url = URL(string: "https://api.sampleapis.com/coffee/hot") else {
                updateWithError(.invalidUrl)
                return
            }
            guard let (data, response) = try? await URLSession.shared.data(from: url) else{
                updateWithError(.requestError)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                updateWithError(.statusNotOk)
                return
            }
            guard let result = try? JSONDecoder().decode([Coffee].self, from: data) else {
                updateWithError(.decodingError)
                return
            }

            logger.log("CoffeeService: Got new coffees", severity: .debug)
            DispatchQueue.main.async {
                self.coffees = result
            }
        }
    }
    
    private func updateWithError(_ error: ApiError) {
        logger.log("CoffeeService: Failed to get coffees with error: \(error)", severity: .error)
        DispatchQueue.main.async {
            self.error = error
        }
    }
}

private struct CoffeeServiceKey: InjectionKey {
    static var currentValue: CoffeeServiceProtocol = CoffeeService()
}

extension InjectedValues {
    var coffeeService: CoffeeServiceProtocol {
        get { Self[CoffeeServiceKey.self] }
        set { Self[CoffeeServiceKey.self] = newValue }
    }
}
