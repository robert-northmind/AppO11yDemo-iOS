//
//  OTelConfig.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation

struct OTelConfig {
    // Put your token here
    let token = ""

    // Put your instanceId here
    let instanceId = ""

    // Put your endpoint url
    // Like this: https://otlp-gateway-prod-eu-west-2.grafana.net/otlp
    let endpointUrl = "https://otlp-gateway-prod-eu-west-2.grafana.net/otlp"

    let serviceName = "AppO11lyDemoService"
    let instrumentationScopeName = "AppO11lyDemoScopeName"
    let instrumentationScopeVersion = "semver:0.1.0"
}
