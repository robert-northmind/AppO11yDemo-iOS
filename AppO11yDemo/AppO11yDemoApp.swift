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
    init() {
        OTelTraces.instance.initialize()
        OTelLogs.instance.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    let logger = OTelLogs.instance.getLogger()
                    logger.log("AppO11yDemo was started", severity: .debug)
                }
        }
    }
}
