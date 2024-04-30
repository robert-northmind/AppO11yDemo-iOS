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

    let serviceName = "AppO11yDemo"
    let deploymentEnvironment = "production"
    let serviceNamespace = "AppO11yDemoNamespace"
    let serviceInstanceId = "app-o11y-test-instance-id"

    let instrumentationScopeName = "AppO11yDemoScope"
    let instrumentationScopeVersion = "semver:1.0.0"
}
