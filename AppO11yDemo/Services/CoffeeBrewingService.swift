//
//  CoffeeBrewingService.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation
import Combine
import OpenTelemetryApi

protocol CoffeeBrewingServiceProtocol {
    var brewingStatusPublisher: Published<CoffeeBrewingStatus>.Publisher { get }

    func brewCoffee(_ coffee: Coffee) async -> Bool
    func cancelBrewing()
}

class CoffeeBrewingService: CoffeeBrewingServiceProtocol {
    @Published var brewingStatus: CoffeeBrewingStatus = WaitingForBaristaBrewingStatus()
    var brewingStatusPublisher: Published<CoffeeBrewingStatus>.Publisher { $brewingStatus }

    private let logger = OTelLogs.instance.getLogger()
    private let tracer = OTelTraces.instance.getTracer()
    
    private var brewingTask: Task<Bool, Never>?

    func brewCoffee(_ coffee: Coffee) async -> Bool {
        logger.log("Starting to brew a new coffee", severity: .info, attributes: ["CoffeeType": coffee.title])
        
        let parentSpan = tracer.spanBuilder(spanName: "BrewingCoffee")
            .setSpanKind(spanKind: .server)
            .startSpan()
        parentSpan.setAttribute(key: "CoffeeType", value: coffee.title.safeTracingName)

        if let brewingTask = brewingTask {
            brewingTask.cancel()
        }
        let task = Task { () -> Bool in
            let childSpan1 = tracer.spanBuilder(spanName: "WaitingForBarista")
                .setParent(parentSpan)
                .setSpanKind(spanKind: .server)
                .startSpan()
            childSpan1.setAttribute(key: "SomeKey", value: "SomeValue")
            
            DispatchQueue.main.async {
                self.brewingStatus = WaitingForBaristaBrewingStatus()
            }
            childSpan1.addEvent(name: "WeGotABarista", attributes: ["baristaName": AttributeValue.string("Cof_Fee")])
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            do { try Task.checkCancellation() } catch {
                childSpan1.end()
                return false
            }
            childSpan1.end()
            
            let childSpan2 = tracer.spanBuilder(spanName: "MakingTheCoffee")
                .setParent(parentSpan)
                .setSpanKind(spanKind: .server)
                .startSpan()
            childSpan2.setAttribute(key: "SomeOtherKey", value: "SomeOtherValue")
            
            DispatchQueue.main.async {
                self.brewingStatus = MakingTheCoffeeBrewingStatus()
            }
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            do { try Task.checkCancellation() } catch {
                childSpan2.end()
                return false
            }
            childSpan2.end()
            
            DispatchQueue.main.async {
                self.brewingStatus = CoffeeIsReadyBrewingStatus()
            }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            return true
        }
        brewingTask = task
        
        let didCompleteBrewing = await task.value
        if didCompleteBrewing {
            parentSpan.status = .ok
            logger.log("Finished making a new nice cup of coffee", severity: .info)
        } else {
            parentSpan.status = .error(description: "Failed_to_make_coffee")
            logger.log("Failed to make coffee", severity: .error)
        }
        parentSpan.end()
        return didCompleteBrewing
    }
    
    func cancelBrewing() {
        if let brewingTask = brewingTask {
            brewingTask.cancel()
        }
        DispatchQueue.main.async {
            self.brewingStatus = WaitingForBaristaBrewingStatus()
        }
    }
}

private struct CoffeeBrewingServiceKey: InjectionKey {
    static var currentValue: CoffeeBrewingServiceProtocol = CoffeeBrewingService()
}

extension InjectedValues {
    var coffeeBrewingService: CoffeeBrewingServiceProtocol {
        get { Self[CoffeeBrewingServiceKey.self] }
        set { Self[CoffeeBrewingServiceKey.self] = newValue }
    }
}

extension String {
    var safeTracingName: String {
        return self.replacingOccurrences(of: " ", with: "_")
    }
}
