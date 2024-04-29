//
//  OTelResourceProvider.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation
import OpenTelemetryApi
import OpenTelemetrySdk
import StdoutExporter
import ResourceExtension
import OpenTelemetryProtocolExporterHttp
import URLSessionInstrumentation

struct OTelResourceProvider {
    func getResource() -> Resource {
        let customResource = Resource.init(
            attributes: ["service.name": AttributeValue.string(OTelConfig().serviceName)]
        )
        return customResource.merging(other: DefaultResources().get())
    }
}
