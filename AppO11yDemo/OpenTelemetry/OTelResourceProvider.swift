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
                "deployment.environment": AttributeValue.string("staging"),
                "service.namespace": AttributeValue.string("coffee"),
                "service.instance.id": AttributeValue.string("coffee-66b6c48dd5-hprdn")
            ]
        )
        return defaultResources.merging(other: customResource)
    }
}
