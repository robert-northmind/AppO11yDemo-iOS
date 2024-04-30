//
//  OTelTraces.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation
import OpenTelemetryApi
import OpenTelemetrySdk
import StdoutExporter
import OpenTelemetryProtocolExporterHttp
import URLSessionInstrumentation

class OTelTraces {
    static let instance = OTelTraces()
    
    private init() {}
    
    private var isInitialized = false

    func initialize() {
        guard isInitialized == false else { return }
        isInitialized = true

        let urlConfig = URLSessionConfiguration.default
        urlConfig.httpAdditionalHeaders = OTelAuthProvider().getAuthHeader()
        
        let otlpHttpTraceExporter = OtlpHttpTraceExporter(
            endpoint: URL(string: "\(OTelConfig().endpointUrl)/v1/traces")!,
            useSession: URLSession(configuration: urlConfig)
        )
        
        let stdoutProcessor = SimpleSpanProcessor(spanExporter: StdoutExporter())
        let otlpHttpTraceProcessor = SimpleSpanProcessor(spanExporter: otlpHttpTraceExporter)
//        let otlpHttpTraceProcessor = BatchSpanProcessor(spanExporter: otlpHttpTraceExporter)
        
        let tracerProvider = TracerProviderBuilder()
            .add(spanProcessor: stdoutProcessor)
            .add(spanProcessor: otlpHttpTraceProcessor)
            .with(resource: OTelResourceProvider().getResource())
            .build()
        OpenTelemetry.registerTracerProvider(tracerProvider:tracerProvider)
        
        let otelEndpointUrl = URL(string: "\(OTelConfig().endpointUrl)/v1/traces")!,
        _ = URLSessionInstrumentation(
            configuration: URLSessionInstrumentationConfiguration(
                shouldInstrument: { request in
                    // Only instrument legitimate API calls and not the calls to the APM collector
                    if request.url?.host() == otelEndpointUrl.host() {
                        return false
                    }
                    return true
                },
                nameSpan: { request in
                    // Sets the name of the span to the relative path of the URL
                    return request.url?.path().split(separator: "/").last?.lowercased()
                },
                spanCustomization: { (request, spanBuilder) in
                    spanBuilder.setSpanKind(spanKind: .server)
                },
                injectCustomHeaders: { request, span in
                    // This section is for injecting headers, we are injecting X-B3 headers to enable context propagation
                    if request.url?.host() == otelEndpointUrl.host() {
                        return
                    }
                    request.setValue(span!.context.traceId.hexString, forHTTPHeaderField: "X-B3-TraceId")
                    request.setValue(span!.context.spanId.hexString, forHTTPHeaderField: "X-B3-SpanId")
                },
                receivedResponse: { response, _, span in
                    if let httpResponse = response as? HTTPURLResponse {
                        // this section is for adding attributes, we are adding the HttpStatusCode attribute
                        span.setAttribute(key: "HttpStatusCode", value: httpResponse.statusCode)
                    }
                },
                receivedError: { _, _, status, span in
                    span.setAttribute(key: "HttpStatusCode", value: status)
                }
            )
        )
    }

    func getTracer() -> Tracer {
        let otelConfig = OTelConfig()
        return OpenTelemetry.instance.tracerProvider.get(
            instrumentationName: otelConfig.instrumentationScopeName,
            instrumentationVersion: otelConfig.instrumentationScopeVersion
        )
    }
}
