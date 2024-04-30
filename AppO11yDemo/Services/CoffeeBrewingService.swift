//
//  CoffeeBrewingService.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation
import Combine
import OpenTelemetryApi
import OpenTelemetrySdk
import StdoutExporter
import OpenTelemetryProtocolExporterHttp
import URLSessionInstrumentation
import ResourceExtension

protocol CoffeeBrewingServiceProtocol {
    var brewingStatusPublisher: Published<CoffeeBrewingStatus>.Publisher { get }

    func brewCoffee(_ coffee: Coffee) async -> Bool
    func cancelBrewing()
}

class CoffeeBrewingService: CoffeeBrewingServiceProtocol {
    @Published var brewingStatus: CoffeeBrewingStatus = WaitingForBaristaBrewingStatus()
    var brewingStatusPublisher: Published<CoffeeBrewingStatus>.Publisher { $brewingStatus }

    private let logger = OTelLogs.instance.getLogger()
    
    private var brewingTask: Task<Bool, Never>?

    func brewCoffee(_ coffee: Coffee) async -> Bool {
        logger.log("Starting to brew a new coffee", severity: .info, attributes: ["CoffeeType": coffee.title])
        
        let provider = OTelTraces.instance.tracerProvider
        let originalResource = provider?.getActiveResource()
        
        let appTracer = OTelTraces.instance.getTracer()
        let parentSpan = appTracer.spanBuilder(spanName: "BrewingCoffee")
            .setSpanKind(spanKind: .server)
            .startSpan()
        parentSpan.setAttribute(key: "CoffeeType", value: coffee.title.safeTracingName)

        if let brewingTask = brewingTask {
            brewingTask.cancel()
        }
        let task = Task { () -> Bool in
            provider?.updateActiveResource(FakeTraceServiceCreator.getBaristaResource())
            
            let appTracer1 = OTelTraces.instance.getTracer()
            let childSpan1 = appTracer1.spanBuilder(spanName: "WaitingForBarista")
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
            
            provider?.updateActiveResource(FakeTraceServiceCreator.getCoffeeMachineResource())
            
            let appTracer2 = OTelTraces.instance.getTracer()
            let childSpan2 = appTracer2.spanBuilder(spanName: "MakingTheCoffee")
                .setParent(childSpan1)
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
        
        if let originalResource = originalResource {
            provider?.updateActiveResource(originalResource)
        }
        
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

struct FakeTraceServiceCreator {
    static func getBaristaResource() -> Resource {
        let defaultResources = DefaultResources().get()
        let customResource = Resource(
            attributes: [
                "service.name": AttributeValue.string("Barista"),
                "deployment.environment": AttributeValue.string("production"),
                "service.namespace": AttributeValue.string("AppO11yDemoNamespaceTest"),
                "service.instance.id": AttributeValue.string("barista-instance-id")
            ]
        )
        let coffeeMachineResource = defaultResources.merging(other: customResource)
        return coffeeMachineResource
    }
    
    static func getCoffeeMachineResource() -> Resource {
        let defaultResources = DefaultResources().get()
        let customResource = Resource(
            attributes: [
                "service.name": AttributeValue.string("CoffeeMachine"),
                "deployment.environment": AttributeValue.string("production"),
                "service.namespace": AttributeValue.string("AppO11yDemoNamespaceTest"),
                "service.instance.id": AttributeValue.string("coffee-machine-instance-id")
            ]
        )
        let coffeeMachineResource = defaultResources.merging(other: customResource)
        return coffeeMachineResource
    }
}
