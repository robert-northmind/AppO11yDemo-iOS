//
//  AppO11yDemoApp.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 26.04.24.
//

import SwiftUI
import OpenTelemetryApi
import OpenTelemetrySdk
import StdoutExporter
import ResourceExtension
import OpenTelemetryProtocolExporterHttp
import URLSessionInstrumentation

@main
struct AppO11yDemoApp: App {
    
    let sampleKey = "sampleKey"
    let sampleValue = "sampleValue"
    
    init() {
        OTelTraces.instance.initialize()
        OTelLogs.instance.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    let logger = OTelLogs.instance.getLogger()
                    logger.log("AppO11yDemo was started", severity: .fatal)
                }
        }
    }
    
    func createSpans() {
        let tracer = OTelTraces.instance.getTracer()
        
        let parentSpan1 = tracer.spanBuilder(spanName: "Main")
            .setSpanKind(spanKind: .client)
            .startSpan()

        parentSpan1.setAttribute(key: sampleKey, value: sampleValue)
        OpenTelemetry.instance.contextProvider.setActiveSpan(parentSpan1)
        for _ in 1...3 {
            doWork()
        }
        Thread.sleep(forTimeInterval: 0.5)
        
        let parentSpan2 = tracer.spanBuilder(spanName: "Another").setSpanKind(spanKind: .client).setActive(true).startSpan()
        parentSpan2.setAttribute(key: sampleKey, value: sampleValue)
        // do more Work
        for _ in 1...3 {
            doWork()
        }
        Thread.sleep(forTimeInterval: 0.5)
        
        parentSpan2.end()
        parentSpan1.end()
    }

    func doWork() {
        let tracer = OTelTraces.instance.getTracer()

        let childSpan = tracer.spanBuilder(spanName: "doWork").setSpanKind(spanKind: .client).startSpan()
        childSpan.setAttribute(key: sampleKey, value: sampleValue)
        Thread.sleep(forTimeInterval: Double.random(in: 0 ..< 10) / 100)
        childSpan.end()
    }
}
