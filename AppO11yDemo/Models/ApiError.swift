//
//  ApiError.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation

enum ApiError: Error {
    case invalidUrl, requestError, decodingError, statusNotOk
}
