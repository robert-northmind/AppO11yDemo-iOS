//
//  OTelResourceProvider.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import OpenTelemetryApi
import OpenTelemetrySdk
import ResourceExtension

struct OTelResourceProvider {
    func getResource() -> Resource {
        let defaultResources = DefaultResources().get()
        let customResource = Resource(
            attributes: [
                "service.name": AttributeValue.string(OTelConfig().serviceName),
                "kind": AttributeValue.string("client")
            ]
        )
        return defaultResources.merging(other: customResource)
    }
}
