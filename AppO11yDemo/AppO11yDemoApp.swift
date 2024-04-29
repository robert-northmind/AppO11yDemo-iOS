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
    let instrumentationScopeName = "AppO11lyDemo"
    let instrumentationScopeVersion = "semver:0.1.0"
    
    let sampleKey = "sampleKey"
    let sampleValue = "sampleValue"
    
    init() {
        let token = ""
        let instanceID = ""
        let credentials = "\(instanceID):\(token)"
        let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() ?? ""
        let authHeader = "Basic \(base64Credentials)"
        
        let otlpEndpointUrl = "https://otlp-gateway-prod-eu-west-2.grafana.net/otlp"
        let urlConfig = URLSessionConfiguration.default
        urlConfig.httpAdditionalHeaders = ["Authorization": authHeader]
        
        let resource1 = Resource.init(
            attributes: ["service.name": AttributeValue.string("AppO11y-iOS-Demo")]
        )
        let resources = resource1.merging(other: DefaultResources().get())
//        let resources = Resource.init(
//            attributes: ["service.name": AttributeValue.string("StableMetricExample")]
//        ).merge(other: DefaultResources().get())
        
        // #################################################################################################
        // MARK: Traces
        let stdoutExporter = StdoutExporter()
        let otlpHttpTraceExporter = OtlpHttpTraceExporter(
            endpoint: URL(string: "https://otlp-gateway-prod-eu-west-2.grafana.net/otlp/v1/traces")!,
            useSession: URLSession(configuration: urlConfig)
        )
        let spanExporter = MultiSpanExporter(spanExporters: [otlpHttpTraceExporter, stdoutExporter])
        let spanProcessor = SimpleSpanProcessor(spanExporter: spanExporter)
//        let spanProcessor = BatchSpanProcessor(spanExporter: spanExporter)
        let tracerProvider = TracerProviderBuilder()
            .add(spanProcessor: spanProcessor)
            .with(resource: resources)
            .build()
        OpenTelemetry.registerTracerProvider(tracerProvider:tracerProvider)
        
//        let networkInstrumentation = URLSessionInstrumentation(configuration: URLSessionInstrumentationConfiguration())
        
//        let tracer1 = OpenTelemetry.instance.tracerProvider.get(
//            instrumentationName: instrumentationScopeName,
//            instrumentationVersion: instrumentationScopeVersion
//        )
//        let tracer2 = OpenTelemetry.instance.tracerProvider.get(
//            instrumentationName: instrumentationScopeName,
//            instrumentationVersion: instrumentationScopeVersion
//        ) as! TracerSdk
        
//        if #available(iOS 12.0, *) {
//            let tracerProviderSDK = OpenTelemetry.instance.tracerProvider as? TracerProviderSdk
//            tracerProviderSDK?.addSpanProcessor(SignPostIntegration())
//        }
        
        // #################################################################################################
        // MARK: Logs
        let otlpHttpLogExporter = OtlpHttpLogExporter(
            endpoint: URL(string: "https://otlp-gateway-prod-eu-west-2.grafana.net/otlp/v1/logs")!,
            useSession: URLSession(configuration: urlConfig)
        )
        let logProcessor = SimpleLogRecordProcessor(logRecordExporter:otlpHttpLogExporter)
//        let logProcessor = BatchLogRecordProcessor(logRecordExporter:otlpHttpLogExporter)
        let loggerProvider = LoggerProviderBuilder()
            .with(processors: [logProcessor])
            .with(resource: resources)
            .build()
        OpenTelemetry.registerLoggerProvider(loggerProvider: loggerProvider)
        
//        // #################################################################################################
//        // MARK: Metrics
//        let otlpHttpMetricExporter = OtlpHttpMetricExporter(
//            endpoint: URL(string: "https://otlp-gateway-prod-us-west-0.grafana.net/otlp/v1/logs")!,
//            useSession: URLSession(configuration: urlConfig)
//        )
//        let processor = MetricProcessorSdk()
//        let meterProvider = MeterProviderSdk(metricProcessor: processor, metricExporter: otlpHttpMetricExporter, metricPushInterval: 0.1)
//        OpenTelemetry.registerMeterProvider(meterProvider: meterProvider)
//
//        var meter = meterProvider.get(instrumentationName: "otlp_example_meter'")
//        var exampleCounter = meter.createIntCounter(name: "otlp_example_counter")
//        
//        let someMetricLabels = ["dim1": "value1"]
//        exampleCounter.add(value: 1, labelset: meter.getLabelSet(labels: someMetricLabels))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .onAppear {
//                    print("I did appear!")
////                    createSpans()
////                    doSomeLogging()
//                }
        }
    }
    
    func doSomeLogging() {
        let logger = OpenTelemetry.instance.loggerProvider.loggerBuilder(instrumentationScopeName: instrumentationScopeName).setEventDomain("ios-device").build()
        let attribs = ["SomeKey": "SomeVal"]
        logger.log("Testing Logs from iOS app. Here is Trace", severity: .trace, timestamp: Date(), attributes: attribs)
        logger.log("Testing Logs from iOS app. Here is Debug", severity: .debug, timestamp: Date(), attributes: attribs)
        logger.log("Testing Logs from iOS app. Here is Info", severity: .info, timestamp: Date(), attributes: attribs)
        logger.log("Testing Logs from iOS app. Here is Error", severity: .error, timestamp: Date(), attributes: attribs)
        logger.log("Testing Logs from iOS app. Here is Fatal", severity: .fatal, timestamp: Date(), attributes: attribs)
    }
    
    func createSpans() {
        let tracer = OpenTelemetry.instance.tracerProvider.get(instrumentationName: instrumentationScopeName, instrumentationVersion: instrumentationScopeVersion)
        
        let parentSpan1 = tracer.spanBuilder(spanName: "Main").setSpanKind(spanKind: .client).startSpan()
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
        print("Doing work")
        let tracer = OpenTelemetry.instance.tracerProvider.get(instrumentationName: instrumentationScopeName, instrumentationVersion: instrumentationScopeVersion)
        
        let childSpan = tracer.spanBuilder(spanName: "doWork").setSpanKind(spanKind: .client).startSpan()
        childSpan.setAttribute(key: sampleKey, value: sampleValue)
        Thread.sleep(forTimeInterval: Double.random(in: 0 ..< 10) / 100)
        childSpan.end()
    }
}

extension Logger {
    func log(
        _ message: String,
        severity: Severity,
        timestamp: Date,
        attributes: [String: String]
    ) {
        let otelAttributes = attributes.reduce(into: [String: AttributeValue]()) {
            $0[$1.key] = AttributeValue.string($1.value)
        }
        self
            .logRecordBuilder()
            .setBody(AttributeValue.string(message))
            .setTimestamp(timestamp)
            .setAttributes(otelAttributes)
            .setSeverity(severity)
            .emit()
    }
}
