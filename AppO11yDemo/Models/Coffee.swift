//
//  Coffee.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation

struct Coffee: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let imageUrl: String
    let ingredients: [String]
    
    private enum CodingKeys: String, CodingKey {
        case title = "title"
        case description = "description"
        case imageUrl = "image"
        case ingredients = "ingredients"
    }
}
