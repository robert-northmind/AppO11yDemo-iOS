//
//  OTelAuthProvider.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation

struct OTelAuthProvider {
    private let otelConfig = OTelConfig()

    func getAuthHeader() -> [String: String] {
        let token = otelConfig.token
        let instanceId = otelConfig.instanceId
        let credentials = "\(instanceId):\(token)"
        
        let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() ?? ""
        let authHeader = "Basic \(base64Credentials)"
        return ["Authorization": authHeader]
    }
}
